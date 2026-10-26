# vuln-lab

A throwaway, **intentionally vulnerable** security practice lab. Everything here is
deliberately broken and all credentials are fake. **Run only on an isolated host — never
expose these ports to a network you don't control.**

One folder per category, each a full upstream project cloned from GitHub.

## Bring it up

```bash
./lab.sh                 # interactive: start targets by name or number
# or directly:
docker compose up -d     # pulls/builds all targets
docker compose down      # tear down
docker compose down -v   # also drop the DVWA database volume
```

`./lab.sh` lists every target with its name so your team can start just the ones
they want, e.g. type `dvwa vampi` or `all`.

## Targets (all on the `vuln-lab` docker network)

| Name           | Category    | Project                     | URL / access                        |
|----------------|-------------|-----------------------------|-------------------------------------|
| dvwa           | Website     | DVWA                        | http://localhost:8080 (setup.php, admin/password) |
| webgoat        | Website     | OWASP WebGoat               | http://localhost:8888/WebGoat (WebWolf :9090) |
| juiceshop      | Website     | OWASP Juice Shop            | http://localhost:3000               |
| vampi          | API         | OWASP VAmPI (REST)          | http://localhost:5000               |
| dvga           | API         | Damn Vulnerable GraphQL     | http://localhost:5013               |
| metasploitable | Network     | Metasploitable 2            | `nmap localhost` ports below        |
| redis          | Network     | Unauthenticated Redis       | `redis-cli -h localhost -p 6379`    |
| sourcecode     | Source code | vulpy (+ git-history leak)  | not served — scan the files         |

### Website — DVWA
Damn Vulnerable Web App (SQLi, XSS, CSRF, command injection, file upload/inclusion, …).
First run: open http://localhost:8080/setup.php → **Create / Reset Database**, then log in
with `admin` / `password`.

### API — VAmPI
Vulnerable REST API (BOLA/IDOR, broken auth, mass assignment, SQLi). Runs in vulnerable
mode. Spec at http://localhost:5000, e.g. `GET /users/v1/_debug` dumps all users.

### Network — Metasploitable 2
Classic intentionally-vulnerable host. Scan and exploit the exposed services:

```bash
nmap -sV -p 2221,2223,8021,8081,3306,5432,6667 localhost
```

| Host port | Service        |
|-----------|----------------|
| 2221      | ssh            |
| 2223      | telnet         |
| 8021      | ftp (vsftpd)   |
| 8081      | http           |
| 3306      | mysql          |
| 5432      | postgres       |
| 6667      | ircd (backdoor)|

### Source code — vulpy + git-history leak
A deliberately insecure Python/Flask codebase (`source-code/vulpy/bad/`) plus a planted
secret in git history. Point static-analysis tools at the folder:

```bash
bandit -r source-code/vulpy/bad/
semgrep --config auto source-code/vulpy/
gitleaks detect --source source-code/

# the AWS keys are only in git history (commit 1), not in HEAD:
cd source-code && git log --oneline && git show $(git rev-list --max-parents=0 HEAD):config.py
```

All AWS values are AWS's published example credentials — not real.
