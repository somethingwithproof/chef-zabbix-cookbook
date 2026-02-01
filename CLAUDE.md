# chef-zabbix-cookbook

## Purpose
Chef cookbook to install and configure Zabbix components: agent, server, frontend, and database backend.

## Stack
- Chef 18+ / Ruby
- ChefSpec (unit), InSpec (integration), Test Kitchen
- Policyfile for dependency management
- Depends on: poise, build-essential, yum-epel, apt, postgresql, mysql, nginx

## Build / Test
```bash
bundle install
bundle exec rspec              # ChefSpec unit tests
bundle exec kitchen test       # Integration tests (Docker)
```

## Standards
- Unified mode for custom resources
- Guard properties on all `execute` resources
- ChefSpec tests in `spec/`, InSpec tests in `test/`
- Cookstyle clean
- Custom resources in `resources/`
