#!/usr/bin/env bash
# Generate local configuration without printing secrets or replacing existing settings.
set -euo pipefail
umask 077

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [[ -L .env ]]; then
  echo 'Refusing to write to a symlink at .env.' >&2
  exit 1
fi
if [[ -e .env ]]; then
  [[ -f .env ]] || { echo '.env must be a regular file.' >&2; exit 1; }
  chmod 600 .env
  echo 'Existing .env preserved (permissions set to 600).'
  exit 0
fi

[[ -f .env.example ]] || { echo 'Missing .env.example.' >&2; exit 1; }
command -v openssl >/dev/null 2>&1 || {
  echo 'OpenSSL is required to generate secure random credentials.' >&2
  exit 1
}

# Optional environment overrides; defaults match .env.example except for credentials.
POSTGRES_USER="${POSTGRES_USER:-app_$(openssl rand -hex 4)}"
POSTGRES_DB="${POSTGRES_DB:-app_$(openssl rand -hex 4)}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-$(openssl rand -hex 32)}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
BACKEND_PORT="${BACKEND_PORT:-8080}"
FRONTEND_PORT="${FRONTEND_PORT:-4200}"

for key in POSTGRES_USER POSTGRES_DB; do
  value="${!key}"
  if [[ ! "$value" =~ ^[a-z_][a-z0-9_]*$ || ${#value} -gt 63 ]]; then
    echo "$key must use lowercase letters, digits, and underscores, start with a letter or underscore, and be at most 63 characters." >&2
    exit 1
  fi
done
# Keep values safe for literal .env interpolation without shell evaluation or escaping.
if [[ ! "$POSTGRES_PASSWORD" =~ ^[a-zA-Z0-9_@%+=:,./-]+$ ]]; then
  echo 'POSTGRES_PASSWORD must contain only letters, digits, or _@%+=:,./-.' >&2
  exit 1
fi
for key in POSTGRES_PORT BACKEND_PORT FRONTEND_PORT; do
  value="${!key}"
  if [[ ! "$value" =~ ^[1-9][0-9]{0,4}$ ]] || (( 10#$value > 65535 )); then
    echo "$key must be an integer between 1 and 65535 without leading zeros." >&2
    exit 1
  fi
done
if [[ "$BACKEND_PORT" == "$FRONTEND_PORT" ]]; then
  echo 'BACKEND_PORT and FRONTEND_PORT must be different.' >&2
  exit 1
fi

TEMP_ENV="$(mktemp "$ROOT_DIR/.env.setup.XXXXXX")"
trap 'rm -f "$TEMP_ENV"' EXIT
while IFS= read -r line || [[ -n "$line" ]]; do
  case "$line" in
    POSTGRES_USER=*|POSTGRES_PASSWORD=*|POSTGRES_DB=*|POSTGRES_PORT=*|BACKEND_PORT=*|FRONTEND_PORT=*)
      key="${line%%=*}"
      printf '%s=%s\n' "$key" "${!key}"
      ;;
    *) printf '%s\n' "$line" ;;
  esac
done < .env.example > "$TEMP_ENV"

# A hard link creates .env atomically and fails if another process created it first.
ln "$TEMP_ENV" .env
echo 'Created .env with database credentials and application ports (permissions 600).'
echo 'Review .env locally, then run: docker-compose up --build'
