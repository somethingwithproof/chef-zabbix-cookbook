# frozen_string_literal: true

unified_mode true

provides :zabbix_agent2

description 'Use the zabbix_agent2 resource to install and configure Zabbix agent 2'

# Installation properties
property :version, String,
         default: lazy { node['zabbix']['agent2']['version'] },
         description: 'The version of Zabbix agent 2 to install'

property :install_method, String,
         equal_to: %w(package),
         default: 'package',
         description: 'Installation method for Zabbix agent 2'

# Configuration properties
property :servers, [Array, String],
         default: lazy { node['zabbix']['agent2']['servers'] },
         coerce: proc { |v| v.is_a?(String) ? [v] : v },
         description: 'List of Zabbix servers for passive checks'

property :servers_active, [Array, String],
         default: lazy { node['zabbix']['agent2']['servers_active'] },
         coerce: proc { |v| v.is_a?(String) ? [v] : v },
         description: 'List of Zabbix servers for active checks'

property :hostname, String,
         default: lazy { node['zabbix']['agent2']['hostname'] },
         description: 'Hostname reported by agent to server'

property :include_dir, String,
         default: lazy { node['zabbix']['agent2']['include_dir'] },
         description: 'Directory for agent2 configuration snippets'

property :log_file, String,
         default: lazy { node['zabbix']['agent2']['log_file'] },
         description: 'Location of agent2 log file'

property :log_level, [Integer, String],
         default: lazy { node['zabbix']['agent2']['log_level'] },
         description: 'Log level for agent2 (0-5)'

property :timeout, [Integer, String],
         default: lazy { node['zabbix']['agent2']['timeout'] },
         description: 'Timeout for processing checks (1-30)'

property :listen_port, [Integer, String],
         default: lazy { node['zabbix']['agent2']['listen_port'] },
         description: 'Port agent2 listens on for server connections'

property :control_socket, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['control_socket'] },
         description: 'Path to the control socket for agent2'

property :tls_connect, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_connect'] },
         description: 'TLS connection mode for active checks'

property :tls_accept, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_accept'] },
         description: 'TLS connection mode for passive checks'

property :tls_psk_identity, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_psk_identity'] },
         description: 'TLS PSK identity string'

property :tls_psk_file, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_psk_file'] },
         description: 'Full path to TLS PSK file'

property :tls_cert_file, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_cert_file'] },
         description: 'Full path to TLS certificate file'

property :tls_key_file, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_key_file'] },
         description: 'Full path to TLS key file'

property :tls_ca_file, [String, NilClass],
         default: lazy { node['zabbix']['agent2']['tls_ca_file'] },
         description: 'Full path to TLS CA file'

# Service properties
property :service_name, String,
         default: 'zabbix-agent2',
         description: 'Name of the agent2 service'

property :service_provider, [String, Symbol, NilClass],
         default: nil,
         description: 'Provider for the agent2 service (auto-detected if nil)'

property :service_enabled, [true, false],
         default: true,
         description: 'Enable the agent2 service'

property :service_auto_start, [true, false],
         default: true,
         description: 'Auto-start the agent2 service'

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

    directory new_resource.include_dir do
      owner node['zabbix']['user']
      group node['zabbix']['group']
      mode '0755'
      recursive true
      action :create
      not_if { ::File.directory?(new_resource.include_dir) }
    end
  end

  def install_package
    package 'zabbix-agent2' do
      action :install
      options '--enablerepo=zabbix' if platform_family?('rhel', 'amazon')
    end
  end

  def configure_agent2
    template node['zabbix']['agent2']['config_file'] do
      source 'zabbix_agent2.conf.erb'
      owner 'root'
      group 'root'
      mode '0640'
      variables(
        servers: new_resource.servers.join(','),
        servers_active: new_resource.servers_active.join(','),
        hostname: new_resource.hostname,
        include_dir: new_resource.include_dir,
        pid_file: node['zabbix']['agent2']['pid_file'],
        log_file: new_resource.log_file,
        log_level: new_resource.log_level,
        timeout: new_resource.timeout,
        listen_port: new_resource.listen_port,
        control_socket: new_resource.control_socket,
        tls_connect: new_resource.tls_connect,
        tls_accept: new_resource.tls_accept,
        tls_psk_identity: new_resource.tls_psk_identity,
        tls_psk_file: new_resource.tls_psk_file,
        tls_cert_file: new_resource.tls_cert_file,
        tls_key_file: new_resource.tls_key_file,
        tls_ca_file: new_resource.tls_ca_file
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
  configure_agent2
  setup_service
end

action :configure do
  configure_agent2
  setup_service
end

action :remove do
  service new_resource.service_name do
    action [:stop, :disable]
    only_if { ::File.exist?("/etc/init.d/#{new_resource.service_name}") || ::File.exist?("/etc/systemd/system/#{new_resource.service_name}.service") }
  end

  package 'zabbix-agent2' do
    action :remove
  end
end
