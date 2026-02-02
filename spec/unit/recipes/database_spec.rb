# frozen_string_literal: true

require 'spec_helper'

describe 'zabbix::database' do
  context 'on Ubuntu 22.04 with postgresql' do
    platform 'ubuntu', '22.04'

    before do
      stub_command('test -f /usr/sbin/zabbix_server').and_return(false)
      stub_command(/psql -tAc/).and_return(false)
      stub_command(/grep -q/).and_return(false)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['zabbix']['server']['database']['type'] = 'postgresql'
        node.normal['zabbix']['server']['database']['host'] = '127.0.0.1'
        node.normal['zabbix']['server']['database']['port'] = 5432
        node.normal['zabbix']['server']['database']['name'] = 'zabbix'
        node.normal['zabbix']['server']['database']['user'] = 'zabbix'
        node.normal['zabbix']['server']['database']['password'] = 'zabbix'
      end
      runner.converge(described_recipe)
    end

    it 'installs postgresql packages' do
      expect(chef_run).to install_package(%w(postgresql postgresql-client))
    end

    it 'enables and starts postgresql service' do
      expect(chef_run).to enable_service('postgresql')
      expect(chef_run).to start_service('postgresql')
    end

    it 'creates the zabbix database user' do
      expect(chef_run).to run_execute('create_zabbix_pg_user')
    end

    it 'creates the zabbix database' do
      expect(chef_run).to run_execute('create_zabbix_pg_database')
    end

    it 'logs database setup completion' do
      expect(chef_run).to write_log('Zabbix database setup completed')
    end
  end

  context 'on Ubuntu 22.04 with mysql' do
    platform 'ubuntu', '22.04'

    before do
      stub_command('test -f /usr/sbin/zabbix_server').and_return(false)
      stub_command(/mysql -u/).and_return(false)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['zabbix']['server']['database']['type'] = 'mysql'
        node.normal['zabbix']['server']['database']['host'] = '127.0.0.1'
        node.normal['zabbix']['server']['database']['port'] = 3306
        node.normal['zabbix']['server']['database']['name'] = 'zabbix'
        node.normal['zabbix']['server']['database']['user'] = 'zabbix'
        node.normal['zabbix']['server']['database']['password'] = 'zabbix'
      end
      runner.converge(described_recipe)
    end

    it 'installs mariadb packages' do
      expect(chef_run).to install_package(%w(mariadb-server mariadb-client))
    end

    it 'enables and starts mariadb service' do
      expect(chef_run).to enable_service('mariadb')
      expect(chef_run).to start_service('mariadb')
    end

    it 'creates the zabbix mysql database' do
      expect(chef_run).to run_execute('create_zabbix_mysql_database')
    end

    it 'creates the zabbix mysql user' do
      expect(chef_run).to run_execute('create_zabbix_mysql_user')
    end

    it 'logs database setup completion' do
      expect(chef_run).to write_log('Zabbix database setup completed')
    end
  end
end
