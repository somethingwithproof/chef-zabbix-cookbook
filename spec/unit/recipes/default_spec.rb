# frozen_string_literal: true

require 'spec_helper'

describe 'zabbix::default' do
  context 'on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    before do
      stub_command('getenforce | grep -i disabled').and_return(true)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['zabbix']['user'] = 'zabbix'
        node.normal['zabbix']['group'] = 'zabbix'
        node.normal['zabbix']['dir'] = '/etc/zabbix'
        node.normal['zabbix']['log_dir'] = '/var/log/zabbix'
        node.normal['zabbix']['run_dir'] = '/var/run/zabbix'
        node.normal['zabbix']['socket_dir'] = '/var/run/zabbix'
        node.normal['zabbix']['tmp_dir'] = '/tmp/zabbix'
        node.normal['zabbix']['home_dir'] = '/var/lib/zabbix'
        node.normal['zabbix']['agent']['enabled'] = true
        node.normal['zabbix']['agent']['version'] = '6.4'
        node.normal['zabbix']['agent']['install_method'] = 'package'
        node.normal['zabbix']['agent']['servers'] = ['127.0.0.1']
        node.normal['zabbix']['agent']['servers_active'] = ['127.0.0.1']
        node.normal['zabbix']['agent']['hostname'] = 'test-host'
        node.normal['zabbix']['agent']['include_dir'] = '/etc/zabbix/zabbix_agentd.d'
        node.normal['zabbix']['agent']['log_file'] = '/var/log/zabbix/zabbix_agentd.log'
        node.normal['zabbix']['agent']['log_level'] = 3
        node.normal['zabbix']['agent']['timeout'] = 3
        node.normal['zabbix']['agent']['listen_port'] = 10050
        node.normal['zabbix']['agent']['enable_remote_commands'] = false
        node.normal['zabbix']['agent']['tls_connect'] = 'unencrypted'
        node.normal['zabbix']['agent']['tls_accept'] = 'unencrypted'
        node.normal['zabbix']['agent']['tls_psk_identity'] = ''
        node.normal['zabbix']['agent']['tls_psk_file'] = ''
        node.normal['zabbix']['agent']['tls_cert_file'] = ''
        node.normal['zabbix']['agent']['tls_key_file'] = ''
        node.normal['zabbix']['agent']['tls_ca_file'] = ''
        node.normal['zabbix']['server']['enabled'] = false
        node.normal['zabbix']['web']['enabled'] = false
        node.normal['zabbix']['java_gateway']['enabled'] = false
      end
      runner.converge(described_recipe)
    end

    it 'includes the repository recipe' do
      expect(chef_run).to include_recipe('zabbix::repository')
    end

    it 'creates the zabbix group' do
      expect(chef_run).to create_group('zabbix')
    end

    it 'creates the zabbix user' do
      expect(chef_run).to create_user('zabbix')
    end

    it 'creates the zabbix config directory' do
      expect(chef_run).to create_directory('/etc/zabbix')
    end

    it 'creates the zabbix log directory' do
      expect(chef_run).to create_directory('/var/log/zabbix')
    end

    it 'creates the zabbix run directory' do
      expect(chef_run).to create_directory('/var/run/zabbix')
    end

    it 'installs zabbix agent when enabled' do
      expect(chef_run).to install_zabbix_agent('zabbix_agent')
    end
  end

  context 'on CentOS 8' do
    platform 'centos', '8'

    before do
      stub_command('getenforce | grep -i disabled').and_return(false)
      stub_command('rpm -q net-snmp-devel').and_return(false)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '8') do |node|
        node.normal['zabbix']['user'] = 'zabbix'
        node.normal['zabbix']['group'] = 'zabbix'
        node.normal['zabbix']['dir'] = '/etc/zabbix'
        node.normal['zabbix']['log_dir'] = '/var/log/zabbix'
        node.normal['zabbix']['run_dir'] = '/var/run/zabbix'
        node.normal['zabbix']['socket_dir'] = '/var/run/zabbix'
        node.normal['zabbix']['tmp_dir'] = '/tmp/zabbix'
        node.normal['zabbix']['home_dir'] = '/var/lib/zabbix'
        node.normal['zabbix']['agent']['enabled'] = true
        node.normal['zabbix']['agent']['version'] = '6.4'
        node.normal['zabbix']['agent']['install_method'] = 'package'
        node.normal['zabbix']['agent']['servers'] = ['127.0.0.1']
        node.normal['zabbix']['agent']['servers_active'] = ['127.0.0.1']
        node.normal['zabbix']['agent']['hostname'] = 'test-host'
        node.normal['zabbix']['agent']['include_dir'] = '/etc/zabbix/zabbix_agentd.d'
        node.normal['zabbix']['agent']['log_file'] = '/var/log/zabbix/zabbix_agentd.log'
        node.normal['zabbix']['agent']['log_level'] = 3
        node.normal['zabbix']['agent']['timeout'] = 3
        node.normal['zabbix']['agent']['listen_port'] = 10050
        node.normal['zabbix']['agent']['enable_remote_commands'] = false
        node.normal['zabbix']['agent']['tls_connect'] = 'unencrypted'
        node.normal['zabbix']['agent']['tls_accept'] = 'unencrypted'
        node.normal['zabbix']['agent']['tls_psk_identity'] = ''
        node.normal['zabbix']['agent']['tls_psk_file'] = ''
        node.normal['zabbix']['agent']['tls_cert_file'] = ''
        node.normal['zabbix']['agent']['tls_key_file'] = ''
        node.normal['zabbix']['agent']['tls_ca_file'] = ''
        node.normal['zabbix']['server']['enabled'] = false
        node.normal['zabbix']['web']['enabled'] = false
        node.normal['zabbix']['java_gateway']['enabled'] = false
      end
      runner.converge(described_recipe)
    end

    it 'includes the repository recipe' do
      expect(chef_run).to include_recipe('zabbix::repository')
    end

    it 'creates the zabbix group' do
      expect(chef_run).to create_group('zabbix')
    end

    it 'installs selinux packages' do
      expect(chef_run).to install_selinux_install('zabbix')
    end
  end
end
