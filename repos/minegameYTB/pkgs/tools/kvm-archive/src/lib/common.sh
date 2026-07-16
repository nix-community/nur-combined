# ─────────────────────────────────────────────
# COLORS
# ─────────────────────────────────────────────

if [[ -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' RESET=''
fi

# ─────────────────────────────────────────────
# LOGGING
# ─────────────────────────────────────────────

log_info()    { echo -e "${BLUE}[INFO]${RESET}  $*"; }
log_ok()      { echo -e "${GREEN}[OK]${RESET}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
log_section() { echo -e "\n${BOLD}══ $* ══${RESET}"; }

die() { log_error "$*"; exit 1; }

# ─────────────────────────────────────────────
# CHECKS
# ─────────────────────────────────────────────

check_root() {
  if [[ "$EUID" -ne 0 ]]; then
    log_error "This script must be run as root."
    echo -e "  ${YELLOW}→ Re-run with:${RESET} sudo $SCRIPT_NAME $*" >&2
    exit 1
  fi
}

check_dependencies() {
  local deps=("virsh" "tar" "gzip" "qemu-img" "pv" "xz" "zstd")
  local missing=()
  for dep in "${deps[@]}"; do
    command -v "$dep" &>/dev/null || missing+=("$dep")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    die "Missing dependencies: ${missing[*]}\n  On NixOS, add to your config: libvirt, qemu, pv, xz, zstd"
  fi
}
