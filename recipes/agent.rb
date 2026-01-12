# frozen_string_literal: true

#
# Cookbook:: zabbix
# Recipe:: agent
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

# Enable agent and run the default recipe
node.override['zabbix']['agent']['enabled'] = true
node.override['zabbix']['server']['enabled'] = false
node.override['zabbix']['web']['enabled'] = false

include_recipe 'zabbix::default'
