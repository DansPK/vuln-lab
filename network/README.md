# Network targets

These targets are prebuilt Docker images — there's no source to build, so they live
only as services in the root [`docker-compose.yml`](../docker-compose.yml). This folder
just documents them.

Start them with the launcher (`./lab.sh` → `metasploitable` / `redis`) or directly:

```bash
docker compose up -d metasploitable redis
```

## Metasploitable 2 (`tleemcjr/metasploitable2`)

Classic intentionally-vulnerable host. Scan and exploit the exposed services:

```bash
nmap -sV -p 2221,2223,8021,8081,3306,5432,6667 localhost
```

| Host port | Service         |
|-----------|-----------------|
| 2221      | ssh             |
| 2223      | telnet          |
| 8021      | ftp (vsftpd)    |
| 8081      | http            |
| 3306      | mysql           |
| 5432      | postgres        |
| 6667      | ircd (backdoor) |

## Unauthenticated Redis (`redis:7-alpine`)

No password, bound to the host — a quick recon/lateral-movement target.

```bash
redis-cli -h localhost -p 6379 info
redis-cli -h localhost -p 6379 KEYS '*'
```
