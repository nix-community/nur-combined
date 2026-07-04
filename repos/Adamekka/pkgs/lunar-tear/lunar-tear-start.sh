#!@runtimeShell@
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: lunar-tear-start [options]

Prepares a runtime directory, runs database migrations, and starts the auth,
CDN, and gRPC services from the packaged Lunar Tear binaries.

Options:
  --data-dir PATH          Runtime directory for db/, assets, and generated secrets.
                           Default: $XDG_DATA_HOME/lunar-tear or $HOME/.local/share/lunar-tear
  --assets-dir PATH        Path to the extracted assets directory. Default: DATA_DIR/assets, created if missing
  --auth-listen ADDR       auth-server bind address. Default: 0.0.0.0:3000
  --auth-url URL           URL lunar-tear uses to reach auth-server. Default: http://localhost:3000
  --cdn-listen ADDR        octo-cdn bind address. Default: 0.0.0.0:8080
  --cdn-public-addr ADDR   Client-facing CDN address. Default: 10.0.2.2:8080
  --grpc-listen ADDR       gRPC server bind address. Default: 0.0.0.0:8003
  --grpc-public-addr ADDR  Client-facing gRPC address. Default: 10.0.2.2:8003
  --octo-url URL           CDN URL passed to lunar-tear. Default: http://CDN_PUBLIC_ADDR
  --admin-listen ADDR      Admin webhook bind address. Only binds when LUNAR_ADMIN_TOKEN is set.
  --no-register            Disable new account registration.
  -h, --help               Show this help.

Environment variables with matching names are also supported, for example
LUNAR_TEAR_DATA_DIR, LUNAR_TEAR_ASSETS_DIR, and LUNAR_TEAR_GRPC_PUBLIC_ADDR.
USAGE
}

die() {
  printf 'lunar-tear-start: %s\n' "$*" >&2
  exit 1
}

require_value() {
  if [ "$#" -lt 2 ] || [ -z "$2" ]; then
    die "$1 requires a value"
  fi
}

data_dir="${LUNAR_TEAR_DATA_DIR:-}"
assets_dir="${LUNAR_TEAR_ASSETS_DIR:-}"
assets_dir_explicit=0
if [ -n "${LUNAR_TEAR_ASSETS_DIR:-}" ]; then
  assets_dir_explicit=1
fi
auth_listen="${LUNAR_TEAR_AUTH_LISTEN:-0.0.0.0:3000}"
auth_url="${LUNAR_TEAR_AUTH_URL:-http://localhost:3000}"
cdn_listen="${LUNAR_TEAR_CDN_LISTEN:-0.0.0.0:8080}"
cdn_public_addr="${LUNAR_TEAR_CDN_PUBLIC_ADDR:-10.0.2.2:8080}"
grpc_listen="${LUNAR_TEAR_GRPC_LISTEN:-0.0.0.0:8003}"
grpc_public_addr="${LUNAR_TEAR_GRPC_PUBLIC_ADDR:-10.0.2.2:8003}"
octo_url="${LUNAR_TEAR_OCTO_URL:-}"
admin_listen="${LUNAR_TEAR_ADMIN_LISTEN:-}"
no_register="${LUNAR_TEAR_NO_REGISTER:-}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --data-dir)
      require_value "$1" "${2:-}"
      data_dir="$2"
      shift 2
      ;;
    --data-dir=*)
      data_dir="${1#*=}"
      shift
      ;;
    --assets-dir)
      require_value "$1" "${2:-}"
      assets_dir="$2"
      assets_dir_explicit=1
      shift 2
      ;;
    --assets-dir=*)
      assets_dir="${1#*=}"
      assets_dir_explicit=1
      shift
      ;;
    --auth-listen)
      require_value "$1" "${2:-}"
      auth_listen="$2"
      shift 2
      ;;
    --auth-listen=*)
      auth_listen="${1#*=}"
      shift
      ;;
    --auth-url)
      require_value "$1" "${2:-}"
      auth_url="$2"
      shift 2
      ;;
    --auth-url=*)
      auth_url="${1#*=}"
      shift
      ;;
    --cdn-listen)
      require_value "$1" "${2:-}"
      cdn_listen="$2"
      shift 2
      ;;
    --cdn-listen=*)
      cdn_listen="${1#*=}"
      shift
      ;;
    --cdn-public-addr)
      require_value "$1" "${2:-}"
      cdn_public_addr="$2"
      shift 2
      ;;
    --cdn-public-addr=*)
      cdn_public_addr="${1#*=}"
      shift
      ;;
    --grpc-listen)
      require_value "$1" "${2:-}"
      grpc_listen="$2"
      shift 2
      ;;
    --grpc-listen=*)
      grpc_listen="${1#*=}"
      shift
      ;;
    --grpc-public-addr)
      require_value "$1" "${2:-}"
      grpc_public_addr="$2"
      shift 2
      ;;
    --grpc-public-addr=*)
      grpc_public_addr="${1#*=}"
      shift
      ;;
    --octo-url)
      require_value "$1" "${2:-}"
      octo_url="$2"
      shift 2
      ;;
    --octo-url=*)
      octo_url="${1#*=}"
      shift
      ;;
    --admin-listen)
      require_value "$1" "${2:-}"
      admin_listen="$2"
      shift 2
      ;;
    --admin-listen=*)
      admin_listen="${1#*=}"
      shift
      ;;
    --no-register)
      no_register=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      [ "$#" -eq 0 ] || die "unexpected positional arguments: $*"
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

if [ -z "$data_dir" ]; then
  if [ -n "${XDG_DATA_HOME:-}" ]; then
    data_dir="$XDG_DATA_HOME/lunar-tear"
  else
    [ -n "${HOME:-}" ] || die 'HOME is required when --data-dir is not set'
    data_dir="$HOME/.local/share/lunar-tear"
  fi
fi

if [ -z "$octo_url" ]; then
  octo_url="http://$cdn_public_addr"
fi

mkdir -p "$data_dir/db"
data_dir="$(cd "$data_dir" && pwd -P)"

if [ -z "$assets_dir" ]; then
  assets_dir="$data_dir/assets"
fi

if [ ! -d "$assets_dir" ]; then
  if [ "$assets_dir_explicit" -eq 1 ]; then
    die "Missing required assets directory: $assets_dir"
  fi
  mkdir -p "$assets_dir"
fi
assets_dir="$(cd "$assets_dir" && pwd -P)"

runtime_assets_dir="$data_dir/assets"
if [ "$assets_dir" != "$runtime_assets_dir" ]; then
  if [ -e "$runtime_assets_dir" ] && [ ! -L "$runtime_assets_dir" ]; then
    die "$runtime_assets_dir already exists and is not a symlink; pass --assets-dir=$runtime_assets_dir or move it aside"
  fi
  if [ -L "$runtime_assets_dir" ]; then
    rm "$runtime_assets_dir"
  fi
  ln -s "$assets_dir" "$runtime_assets_dir"
fi

if [ ! -f "$runtime_assets_dir/release/20240404193219.bin.e" ]; then
  die "Missing required asset: $runtime_assets_dir/release/20240404193219.bin.e"
fi

tree_exists() {
  [ -f "$1/list.bin" ] && [ -d "$1/assetbundle" ] && [ -d "$1/resources" ]
}

if ! tree_exists "$runtime_assets_dir/revisions/0" \
  && ! tree_exists "$runtime_assets_dir/revisions/0/android" \
  && ! tree_exists "$runtime_assets_dir/revisions/0/ios"; then
  die "Missing required asset tree under $runtime_assets_dir/revisions/0"
fi

secret_file="$data_dir/auth-secret.hex"
if [ ! -f "$secret_file" ]; then
  umask 077
  od -An -N32 -tx1 /dev/urandom | tr -d ' \n' > "$secret_file"
fi
auth_secret="$(tr -d ' \n' < "$secret_file")"
if [ "${#auth_secret}" -ne 64 ]; then
  die "$secret_file must contain a 64-character hex auth secret"
fi
case "$auth_secret" in
  *[!0-9a-fA-F]*) die "$secret_file must contain only hex characters" ;;
esac

printf 'Running database migrations in %s\n' "$data_dir/db"
"@goose@" -dir "@migrationsDir@" -allow-missing sqlite3 "$data_dir/db/game.db" up

printf 'Starting Lunar Tear services\n'
printf '  data:   %s\n' "$data_dir"
printf '  assets: %s\n' "$assets_dir"
printf '  auth:   %s (%s)\n' "$auth_listen" "$auth_url"
printf '  cdn:    %s public %s\n' "$cdn_listen" "$cdn_public_addr"
printf '  grpc:   %s public %s\n' "$grpc_listen" "$grpc_public_addr"

cd "$data_dir"

pids=()

cleanup() {
  trap - EXIT INT TERM
  if [ "${#pids[@]}" -gt 0 ]; then
    kill "${pids[@]}" 2>/dev/null || true
    wait "${pids[@]}" 2>/dev/null || true
  fi
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM
trap cleanup EXIT

auth_args=(--listen "$auth_listen" --db "$data_dir/db/auth.db" --secret "$auth_secret")
if [ -n "$no_register" ]; then
  auth_args+=(--no-register)
fi
"@packageBinDir@/auth-server" "${auth_args[@]}" &
pids+=("$!")

"@packageBinDir@/octo-cdn" \
  --listen "$cdn_listen" \
  --public-addr "$cdn_public_addr" \
  --assets-dir "$data_dir" &
pids+=("$!")

grpc_args=(
  --listen "$grpc_listen"
  --public-addr "$grpc_public_addr"
  --db "$data_dir/db/game.db"
  --octo-url "$octo_url"
  --auth-url "$auth_url"
)
if [ -n "$admin_listen" ]; then
  grpc_args+=(--admin-listen "$admin_listen")
fi
if [ -n "$no_register" ]; then
  grpc_args+=(--no-register)
fi
"@packageBinDir@/lunar-tear" "${grpc_args[@]}" &
pids+=("$!")

set +e
wait -n "${pids[@]}"
status=$?
set -e
cleanup
exit "$status"
