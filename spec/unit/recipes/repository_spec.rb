# frozen_string_literal: true

require 'spec_helper'

describe 'zabbix::repository' do
  context 'on Ubuntu 22.04' do
    platform 'ubuntu', '22.04'

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '22.04') do |node|
        node.normal['zabbix']['version'] = '6.4'
        node.normal['zabbix']['repository_key'] = 'https://repo.zabbix.com/zabbix-official-repo.key'
      end
      runner.converge(described_recipe)
    end

    it 'updates apt cache' do
      expect(chef_run).to update_apt_update('update')
    end

    it 'installs transport packages' do
      expect(chef_run).to install_package(%w(apt-transport-https ca-certificates gnupg curl))
    end

    it 'adds the zabbix apt repository' do
      expect(chef_run).to add_apt_repository('zabbix')
    end

    it 'does not add non-supported apt repository for Zabbix 6.x+' do
      expect(chef_run).not_to add_apt_repository('zabbix-non-supported')
    end

    it 'installs common dependencies' do
      expect(chef_run).to install_package(%w(curl libcurl4 libcurl4-openssl-dev snmp libsnmp-dev))
    end

    it 'runs the repo cache refresh' do
      expect(chef_run).to run_execute('zabbix-repo-cache-refresh')
    end
  end

  context 'on CentOS 8' do
    platform 'centos', '8'

    before do
      stub_command('rpm -q net-snmp-devel').and_return(false)
    end

    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(platform: 'centos', version: '8') do |node|
        node.normal['zabbix']['version'] = '6.4'
        node.normal['zabbix']['repository_uri'] = 'https://repo.zabbix.com/zabbix/6.4/rhel/8/$basearch/'
        node.normal['zabbix']['repository_key'] = 'https://repo.zabbix.com/RPM-GPG-KEY-ZABBIX-A14FE591'
      end
      runner.converge(described_recipe)
    end

    it 'includes the yum-epel recipe' do
      expect(chef_run).to include_recipe('yum-epel')
    end

    it 'creates the zabbix yum repository' do
      expect(chef_run).to create_yum_repository('zabbix')
    end

    it 'creates the zabbix-non-supported yum repository' do
      expect(chef_run).to create_yum_repository('zabbix-non-supported')
    end

    it 'installs common dependencies' do
      expect(chef_run).to run_execute('install-zabbix-rhel-deps')
    end

    it 'runs the repo cache refresh' do
      expect(chef_run).to run_execute('zabbix-repo-cache-refresh')
    end
  end
end
