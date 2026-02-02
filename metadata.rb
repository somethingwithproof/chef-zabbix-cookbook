# frozen_string_literal: true

name 'zabbix'
maintainer 'Thomas Vincent'
maintainer_email 'thomasvincent@gmail.com'
license 'Apache-2.0'
description 'Installs and configures Zabbix'
version '1.0.0'
chef_version '>= 18.0'
source_url 'https://github.com/thomasvincent/chef-zabbix-cookbook'
issues_url 'https://github.com/thomasvincent/chef-zabbix-cookbook/issues'

# Supported platforms - tested with Docker/Dokken
supports 'ubuntu', '>= 22.04'
supports 'debian', '>= 12.0'
supports 'redhat', '>= 9.0'
supports 'rocky', '>= 9.0'
supports 'almalinux', '>= 9.0'
supports 'amazon', '>= 2023.0'
depends 'yum-epel', '>= 4.1'
depends 'apt', '>= 7.0'
# postgresql and mysql cookbooks not used - database.rb installs packages directly
depends 'nginx', '>= 12.0'
depends 'apache2', '>= 9.0'
depends 'selinux', '>= 6.0'
