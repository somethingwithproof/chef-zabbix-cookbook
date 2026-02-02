# frozen_string_literal: true

#
# Cookbook:: zabbix
# Recipe:: database
#
# Copyright:: 2023, Thomas Vincent
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set up the required database for Zabbix.
#
# Modern mysql/postgresql community cookbooks no longer provide ::server
# recipes. This recipe installs database servers using native packages
# and configures them with shell commands for maximum compatibility.

db_type = node['zabbix']['server']['database']['type']
db_name = node['zabbix']['server']['database']['name']
db_user = node['zabbix']['server']['database']['user']
db_password = node['zabbix']['server']['database']['password']
db_host = node['zabbix']['server']['database']['host']

case db_type
when 'postgresql'
  # Install PostgreSQL server and client packages
  case node['platform_family']
  when 'debian'
    package %w(postgresql postgresql-client) do
      action :install
    end
  when 'rhel', 'amazon', 'fedora'
    package %w(postgresql-server postgresql) do
      action :install
    end

    # Initialize PostgreSQL database on RHEL-family systems
    execute 'postgresql-initdb' do
      command 'postgresql-setup --initdb || postgresql-setup initdb'
      not_if { ::File.exist?('/var/lib/pgsql/data/PG_VERSION') }
    end
  end

  # Enable and start PostgreSQL service
  service 'postgresql' do
    action [:enable, :start]
  end

  # Configure pg_hba.conf to allow password authentication for the zabbix user
  execute 'configure_pg_hba' do
    command <<-BASH
      PG_HBA=$(find /etc/postgresql /var/lib/pgsql -name pg_hba.conf 2>/dev/null | head -1)
      if [ -n "$PG_HBA" ]; then
        if ! grep -q "#{db_user}" "$PG_HBA"; then
          sed -i "1i host    #{db_name}    #{db_user}    127.0.0.1/32    md5" "$PG_HBA"
          sed -i "1i local   #{db_name}    #{db_user}                    md5" "$PG_HBA"
        fi
      fi
    BASH
    notifies :reload, 'service[postgresql]', :immediately
  end

  # Create Zabbix database user
  execute 'create_zabbix_pg_user' do
    command "psql -c \"CREATE ROLE #{db_user} WITH LOGIN PASSWORD '#{db_password}';\""
    user 'postgres'
    not_if "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='#{db_user}'\" | grep -q 1", user: 'postgres'
    sensitive true
  end

  # Create Zabbix database
  execute 'create_zabbix_pg_database' do
    command "psql -c \"CREATE DATABASE #{db_name} OWNER #{db_user} ENCODING 'UTF-8' TEMPLATE template0 LC_COLLATE 'en_US.UTF-8' LC_CTYPE 'en_US.UTF-8';\""
    user 'postgres'
    not_if "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='#{db_name}'\" | grep -q 1", user: 'postgres'
  end

  # Import Zabbix schema (modern Zabbix uses create.sql.gz, older uses separate files)
  execute 'import_zabbix_pgsql_schema' do
    command lazy {
      schema_file = Dir.glob('/usr/share/doc/zabbix-server-pgsql*/create.sql.gz').first ||
                    Dir.glob('/usr/share/doc/zabbix-server-pgsql*/schema.sql').first
      if schema_file.nil?
        'echo "No Zabbix schema file found, skipping import"'
      elsif schema_file.end_with?('.gz')
        "zcat #{schema_file} | PGPASSWORD='#{db_password}' psql -U #{db_user} -h #{db_host} -d #{db_name}"
      else
        "PGPASSWORD='#{db_password}' psql -U #{db_user} -h #{db_host} -d #{db_name} -f #{schema_file}"
      end
    }
    sensitive true
    not_if "PGPASSWORD='#{db_password}' psql -U #{db_user} -h #{db_host} -d #{db_name} -tAc \"SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='users'\" | grep -q '^[1-9]'",
           environment: { 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
    only_if 'test -f /usr/sbin/zabbix_server', environment: { 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
  end

  # Import images and data (older Zabbix versions use separate files)
  %w(images data).each do |file_type|
    execute "import_zabbix_pgsql_#{file_type}" do
      command lazy {
        sql_file = Dir.glob("/usr/share/doc/zabbix-server-pgsql*/#{file_type}.sql").first
        if sql_file.nil?
          "echo 'No #{file_type}.sql found (may be combined in create.sql.gz), skipping'"
        else
          "PGPASSWORD='#{db_password}' psql -U #{db_user} -h #{db_host} -d #{db_name} -f #{sql_file}"
        end
      }
      sensitive true
      not_if "PGPASSWORD='#{db_password}' psql -U #{db_user} -h #{db_host} -d #{db_name} -tAc \"SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name='users'\" | grep -q '^[1-9]'",
             environment: { 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
      only_if 'test -f /usr/sbin/zabbix_server', environment: { 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
    end
  end

when 'mysql'
  # Install MariaDB server and client packages (MariaDB is the default
  # drop-in replacement available on all supported platforms)
  case node['platform_family']
  when 'debian'
    package %w(mariadb-server mariadb-client) do
      action :install
    end
  when 'rhel', 'amazon', 'fedora'
    package %w(mariadb-server mariadb) do
      action :install
    end
  end

  mysql_service = 'mariadb'

  # Enable and start MariaDB service
  service mysql_service do
    action [:enable, :start]
  end

  # Create Zabbix database
  execute 'create_zabbix_mysql_database' do
    command "mysql -e \"CREATE DATABASE IF NOT EXISTS #{db_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;\""
    sensitive true
  end

  # Create Zabbix database user and grant privileges
  execute 'create_zabbix_mysql_user' do
    command <<-BASH
      mysql -e "CREATE USER IF NOT EXISTS '#{db_user}'@'localhost' IDENTIFIED BY '#{db_password}';"
      mysql -e "CREATE USER IF NOT EXISTS '#{db_user}'@'%' IDENTIFIED BY '#{db_password}';"
      mysql -e "GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'localhost';"
      mysql -e "GRANT ALL PRIVILEGES ON #{db_name}.* TO '#{db_user}'@'%';"
      mysql -e "SET GLOBAL log_bin_trust_function_creators = 1;"
      mysql -e "FLUSH PRIVILEGES;"
    BASH
    sensitive true
  end

  # Import Zabbix schema
  execute 'import_zabbix_mysql_schema' do
    command lazy {
      schema_file = Dir.glob('/usr/share/doc/zabbix-server-mysql*/create.sql.gz').first ||
                    Dir.glob('/usr/share/doc/zabbix-server-mysql*/schema.sql').first
      if schema_file.nil?
        'echo "No Zabbix schema file found, skipping import"'
      elsif schema_file.end_with?('.gz')
        "zcat #{schema_file} | mysql -u#{db_user} -h#{db_host} #{db_name}"
      else
        "mysql -u#{db_user} -h#{db_host} #{db_name} < #{schema_file}"
      end
    }
    environment({ 'MYSQL_PWD' => db_password })
    sensitive true
    not_if "mysql -u#{db_user} -h#{db_host} -e \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='#{db_name}' AND table_name='users'\" | grep -q '[1-9]'",
           environment: { 'MYSQL_PWD' => db_password, 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
    only_if 'test -f /usr/sbin/zabbix_server', environment: { 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
  end

  # Import images and data (older Zabbix versions use separate files)
  %w(images data).each do |file_type|
    execute "import_zabbix_mysql_#{file_type}" do
      command lazy {
        sql_file = Dir.glob("/usr/share/doc/zabbix-server-mysql*/#{file_type}.sql").first
        if sql_file.nil?
          "echo 'No #{file_type}.sql found (may be combined in create.sql.gz), skipping'"
        else
          "mysql -u#{db_user} -h#{db_host} #{db_name} < #{sql_file}"
        end
      }
      environment({ 'MYSQL_PWD' => db_password })
      sensitive true
      not_if "mysql -u#{db_user} -h#{db_host} -e \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='#{db_name}' AND table_name='users'\" | grep -q '[1-9]'",
             environment: { 'MYSQL_PWD' => db_password, 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
      only_if 'test -f /usr/sbin/zabbix_server', environment: { 'PATH' => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
    end
  end
end

# Log successful database setup
log 'Zabbix database setup completed' do
  level :info
end
