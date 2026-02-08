# CLAUDE.md

Chef cookbook for Zabbix monitoring system (agent, server, web frontend).

## Stack
- Ruby / Chef 18.0+
- Test Kitchen + InSpec
- Dependencies: nginx/apache2, yum-epel, apt

## Lint & Test
```bash
cookstyle .
kitchen test
```

## Notes
- Supports MySQL and PostgreSQL database backends
- Custom resources: zabbix_agent, zabbix_server, zabbix_web
- Web frontend works with both Nginx and Apache
