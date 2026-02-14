# frozen_string_literal: true

unified_mode true

provides :zabbix_proxy

description 'Use the zabbix_proxy resource to install and configure Zabbix proxy'

# Installation properties
property :version, String,
         default: lazy { node['zabbix']['proxy']['version'] },
         description: 'The version of Zabbix proxy to install'

property :install_method, String,
         equal_to: %w(package source),
         default: 'package',
         description: 'Installation method for Zabbix proxy'

# Proxy mode properties
property :proxy_mode, [Integer, String],
         default: lazy { node['zabbix']['proxy']['mode'] },
         description: 'Proxy operating mode (0=active, 1=passive)'

property :server, String,
         default: lazy { node['zabbix']['proxy']['server'] },
         description: 'Zabbix server hostname or IP for the proxy to connect to'

property :server_port, [Integer, String],
         default: lazy { node['zabbix']['proxy']['server_port'] },
         description: 'Zabbix server port'

property :hostname, String,
         default: lazy { node['zabbix']['proxy']['hostname'] },
         description: 'Proxy hostname as registered in Zabbix server'

property :listen_port, [Integer, String],
         default: lazy { node['zabbix']['proxy']['listen_port'] },
         description: 'Port proxy listens on for passive checks'

# Database properties
property :database_type, String,
         equal_to: %w(sqlite postgresql mysql),
         default: lazy { node['zabbix']['proxy']['database']['type'] },
         description: 'Type of database to use with Zabbix proxy'

property :database_host, String,
         default: lazy { node['zabbix']['proxy']['database']['host'] },
         description: 'Database server hostname'

property :database_port, [Integer, String],
         default: lazy { node['zabbix']['proxy']['database']['port'] },
         description: 'Database server port'

property :database_name, String,
         default: lazy { node['zabbix']['proxy']['database']['name'] },
         description: 'Database name for Zabbix proxy'

property :database_user, String,
         default: lazy { node['zabbix']['proxy']['database']['user'] },
         description: 'Database username for Zabbix proxy'

property :database_password, String,
         default: lazy { node['zabbix']['proxy']['database']['password'] },
         sensitive: true,
         description: 'Database password for Zabbix proxy'

property :database_socket, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['database']['socket'] },
         description: 'Database socket path'

# Configuration properties
property :config_file, String,
         default: lazy { node['zabbix']['proxy']['config_file'] },
         description: 'Path to proxy configuration file'

property :pid_file, String,
         default: lazy { node['zabbix']['proxy']['pid_file'] },
         description: 'Location of PID file'

property :log_file, String,
         default: lazy { node['zabbix']['proxy']['log_file'] },
         description: 'Location of proxy log file'

property :log_level, [Integer, String],
         default: lazy { node['zabbix']['proxy']['log_level'] },
         description: 'Log level for proxy (0-5)'

property :timeout, [Integer, String],
         default: lazy { node['zabbix']['proxy']['timeout'] },
         description: 'Timeout for operations'

property :config_frequency, [Integer, String],
         default: lazy { node['zabbix']['proxy']['config_frequency'] },
         description: 'How often proxy retrieves configuration data from server (seconds)'

property :data_sender_frequency, [Integer, String],
         default: lazy { node['zabbix']['proxy']['data_sender_frequency'] },
         description: 'Proxy data flush interval (seconds)'

property :heartbeat_frequency, [Integer, String],
         default: lazy { node['zabbix']['proxy']['heartbeat_frequency'] },
         description: 'Heartbeat frequency (seconds)'

property :start_pollers, [Integer, String],
         default: lazy { node['zabbix']['proxy']['start_pollers'] },
         description: 'Number of poller processes to start'

property :start_ipmi_pollers, [Integer, String],
         default: lazy { node['zabbix']['proxy']['start_ipmi_pollers'] },
         description: 'Number of IPMI poller processes to start'

property :start_trappers, [Integer, String],
         default: lazy { node['zabbix']['proxy']['start_trappers'] },
         description: 'Number of trapper processes to start'

property :start_pingers, [Integer, String],
         default: lazy { node['zabbix']['proxy']['start_pingers'] },
         description: 'Number of pinger processes to start'

property :start_discoverers, [Integer, String],
         default: lazy { node['zabbix']['proxy']['start_discoverers'] },
         description: 'Number of discoverer processes to start'

property :cache_size, String,
         default: lazy { node['zabbix']['proxy']['cache_size'] },
         description: 'Size of configuration cache'

# TLS properties
property :tls_connect, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_connect'] },
         description: 'TLS connection mode for outgoing connections to server'

property :tls_accept, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_accept'] },
         description: 'TLS connection mode for incoming connections'

property :tls_cert_file, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_cert_file'] },
         description: 'Full path to TLS certificate file'

property :tls_key_file, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_key_file'] },
         description: 'Full path to TLS key file'

property :tls_ca_file, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_ca_file'] },
         description: 'Full path to TLS CA file'

property :tls_psk_identity, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_psk_identity'] },
         description: 'TLS PSK identity string'

property :tls_psk_file, [String, NilClass],
         default: lazy { node['zabbix']['proxy']['tls_psk_file'] },
         description: 'Full path to TLS PSK file'

# Service properties
property :service_name, String,
         default: 'zabbix-proxy',
         description: 'Name of the proxy service'

property :service_provider, [String, Symbol, NilClass],
         default: nil,
         description: 'Provider for the proxy service (auto-detected if nil)'

property :service_enabled, [true, false],
         default: true,
         description: 'Enable the proxy service'

property :service_auto_start, [true, false],
         default: true,
         description: 'Auto-start the proxy service'

action_class do
  def create_directories
    %w(
      dir
      log_dir
      run_dir
      socket_dir
    ).each do |dir|
      directory node['zabbix'][dir] do
        owner node['zabbix']['user']
        group node['zabbix']['group']
        mode '0755'
        recursive true
        action :create
        not_if { ::File.directory?(node['zabbix'][dir]) }
      end
    end
  end

  def install_package
    proxy_package = case new_resource.database_type
                    when 'sqlite'
                      'zabbix-proxy-sqlite3'
                    when 'postgresql'
                      'zabbix-proxy-pgsql'
                    when 'mysql'
                      'zabbix-proxy-mysql'
                    end

    package proxy_package do
      action :install
      options '--enablerepo=zabbix' if platform_family?('rhel', 'amazon')
    end
  end

  def configure_proxy
    template new_resource.config_file do
      source 'zabbix_proxy.conf.erb'
      owner 'root'
      group node['zabbix']['group']
      mode '0640'
      variables(
        proxy_mode: new_resource.proxy_mode,
        server: new_resource.server,
        server_port: new_resource.server_port,
        hostname: new_resource.hostname,
        listen_port: new_resource.listen_port,
        db_type: new_resource.database_type,
        db_host: new_resource.database_host,
        db_port: new_resource.database_port,
        db_name: new_resource.database_name,
        db_user: new_resource.database_user,
        db_password: new_resource.database_password,
        db_socket: new_resource.database_socket,
        log_file: new_resource.log_file,
        log_level: new_resource.log_level,
        pid_file: new_resource.pid_file,
        timeout: new_resource.timeout,
        config_frequency: new_resource.config_frequency,
        data_sender_frequency: new_resource.data_sender_frequency,
        heartbeat_frequency: new_resource.heartbeat_frequency,
        start_pollers: new_resource.start_pollers,
        start_ipmi_pollers: new_resource.start_ipmi_pollers,
        start_trappers: new_resource.start_trappers,
        start_pingers: new_resource.start_pingers,
        start_discoverers: new_resource.start_discoverers,
        cache_size: new_resource.cache_size,
        tls_connect: new_resource.tls_connect,
        tls_accept: new_resource.tls_accept,
        tls_cert_file: new_resource.tls_cert_file,
        tls_key_file: new_resource.tls_key_file,
        tls_ca_file: new_resource.tls_ca_file,
        tls_psk_identity: new_resource.tls_psk_identity,
        tls_psk_file: new_resource.tls_psk_file
      )
      notifies :restart, "service[#{new_resource.service_name}]", :delayed
    end
  end

  def setup_service
    service new_resource.service_name do
      supports status: true, start: true, stop: true, restart: true
      provider new_resource.service_provider unless new_resource.service_provider.nil?
      action [:enable, :start]
      only_if { new_resource.service_enabled && new_resource.service_auto_start }
    end
  end
end

action :install do
  group node['zabbix']['group'] do
    system true
    action :create
  end

  user node['zabbix']['user'] do
    comment 'Zabbix user'
    gid node['zabbix']['group']
    system true
    shell '/bin/false'
    home node['zabbix']['home_dir']
    action :create
  end

  create_directories
  install_package
  configure_proxy
  setup_service
end

action :configure do
  configure_proxy
  setup_service
end

action :remove do
  service new_resource.service_name do
    action [:stop, :disable]
    only_if { ::File.exist?("/etc/init.d/#{new_resource.service_name}") || ::File.exist?("/etc/systemd/system/#{new_resource.service_name}.service") }
  end

  proxy_package = case new_resource.database_type
                  when 'sqlite'
                    'zabbix-proxy-sqlite3'
                  when 'postgresql'
                    'zabbix-proxy-pgsql'
                  when 'mysql'
                    'zabbix-proxy-mysql'
                  end

  package proxy_package do
    action :remove
  end
end
