#!/usr/bin/env bash
# vuln-lab launcher. Start targets by NAME (or number). Everything here is
# intentionally vulnerable — run only on an isolated host.
set -euo pipefail
cd "$(dirname "$0")"

dc() { docker compose "$@"; }

# name | category | compose service(s) | description / access
# "scan" as the service means run the static-analysis action instead of docker.
TARGETS=(
  "dvwa|Website|dvwa dvwa-db|DVWA — http://localhost:8080 (setup.php, then admin/password)"
  "webgoat|Website|webgoat|OWASP WebGoat — http://localhost:8888/WebGoat (+ WebWolf :9090)"
  "juiceshop|Website|juice-shop|OWASP Juice Shop — http://localhost:3000"
  "vampi|API|vampi|OWASP VAmPI (REST) — http://localhost:5000"
  "dvga|API|dvga|Damn Vulnerable GraphQL — http://localhost:5013"
  "metasploitable|Network|metasploitable|Metasploitable 2 — nmap localhost:2221,2223,8021,8081,3306,5432,6667"
  "redis|Network|redis|Unauth Redis — redis-cli -h localhost -p 6379"
  "sourcecode|Source|scan|vulpy + git-leak — static-analysis scan (no server)"
)

field() { echo "$1" | cut -d'|' -f"$2"; }

menu() {
  echo
  echo "vuln-lab — start target(s) by name or number, space/comma-separated (e.g. 'dvwa vampi' or '1 4'):"
  local i=1 last_cat=""
  for t in "${TARGETS[@]}"; do
    local cat; cat=$(field "$t" 2)
    [ "$cat" != "$last_cat" ] && { echo "  --- $cat ---"; last_cat="$cat"; }
    printf "  %2d) %-16s %s\n" "$i" "$(field "$t" 1)" "$(field "$t" 4)"
    i=$((i+1))
  done
  cat <<'EOF'
  --- commands ---
      all      start every target
      stop     docker compose down
      status   docker compose ps
      q        quit
EOF
}

scan_source() {
  echo ">> scanning source-code/ ..."
  command -v gitleaks >/dev/null && { gitleaks detect --source source-code/ || true; } || echo "   (gitleaks not installed)"
  command -v bandit   >/dev/null && { bandit -r source-code/vulpy/bad/ || true; }       || echo "   (bandit not installed — pip install bandit)"
  echo ">> AWS keys live only in git history:"
  ( cd source-code && git log --oneline && git show "$(git rev-list --max-parents=0 HEAD)":config.py )
}

start_target() {  # $1 = a TARGETS line
  local svc; svc=$(field "$1" 3)
  if [ "$svc" = "scan" ]; then scan_source; else dc up -d $svc; fi
}

resolve() {  # $1 = token (name or number) -> echoes the TARGETS line, or nothing
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    [ "$1" -ge 1 ] && [ "$1" -le "${#TARGETS[@]}" ] && echo "${TARGETS[$(($1-1))]}"
  else
    for t in "${TARGETS[@]}"; do [ "$(field "$t" 1)" = "$1" ] && { echo "$t"; return; }; done
  fi
}

run_one() {
  case "$1" in
    all)    dc up -d ;;
    stop)   dc down ;;
    status) dc ps ;;
    q|Q)    exit 0 ;;
    *)
      local t; t=$(resolve "$1")
      [ -n "$t" ] && start_target "$t" || echo "unknown target: $1"
      ;;
  esac
}

while true; do
  menu
  read -rp "> " line
  for choice in ${line//,/ }; do run_one "$choice"; done
done
