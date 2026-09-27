#!/bin/sh
# rfetch universal installer
# works on debian/ubuntu, fedora/rhel, arch, alpine, void, gentoo, opensuse,
# nixos, freebsd, netbsd, openbsd, macos and anything else with a POSIX shell.
#
#   curl -fsSL https://raw.githubusercontent.com/skerrixx/rfetch/main/install.sh | sh
#
# variables that cross function boundaries are uppercase, function local ones
# carry a short prefix of their function, so no `local` (not POSIX) is needed.
#
set -eu

REPO="${RFETCH_REPO:-skerrixx/rfetch}"
REQUESTED_VERSION="${RFETCH_VERSION:-latest}"
INSTALL_DIR="${RFETCH_INSTALL_DIR:-}"
PREFIX="${RFETCH_PREFIX:-/usr/local}"
BIN_NAME="${RFETCH_BIN:-rfetch}"
USE_MUSL=0
PLAIN=0
ASSUME_YES=0
UNINSTALL=0
NO_DEPS=0
TMPDIR_RF=""
TAG=""
PREBUILT_NAME=""

# ---------------------------------------------------------------- output ----

setup_style() {
	if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "$PLAIN" -eq 0 ]; then
		C_RESET=$(printf '\033[0m')
		C_BOLD=$(printf '\033[1m')
		C_DIM=$(printf '\033[2m')
		C_RED=$(printf '\033[31m')
		C_GRN=$(printf '\033[32m')
		C_YEL=$(printf '\033[33m')
		C_BLU=$(printf '\033[34m')
	else
		C_RESET=""
		C_BOLD=""
		C_DIM=""
		C_RED=""
		C_GRN=""
		C_YEL=""
		C_BLU=""
	fi

	case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in
	*UTF-8* | *UTF8* | *utf-8* | *utf8*) uni=1 ;;
	*) uni=0 ;;
	esac
	[ "$PLAIN" -eq 0 ] || uni=0

	if [ "$uni" -eq 1 ]; then
		G_STEP=$(printf '\302\267')
		G_OK=$(printf '+')
		G_DONE=$(printf '\342\234\223')
		G_WARN=$(printf '!')
		G_ERR=$(printf '\342\234\227')
		G_SEP=$(printf '\302\267')
		G_ARR=$(printf '\342\206\222')
	else
		G_STEP="-"
		G_OK="+"
		G_DONE="ok"
		G_WARN="!"
		G_ERR="x"
		G_SEP="|"
		G_ARR="->"
	fi
}

banner() {
	printf '\n  %srfetch%s %sinstaller%s\n' "$C_BLU" "$C_RESET" "$C_BOLD" "$C_RESET"
	printf '  %s%s%s\n' "$C_DIM" "$1" "$C_RESET"
}

sys_meta() {
	sm_distro=$(os_field ID)
	if [ -z "$sm_distro" ]; then
		sm_distro=$(os_field NAME)
	fi
	sm_meta="${sm_distro:-unknown} $G_SEP $ARCH"
	if [ "$KERNEL" = Linux ]; then
		if is_musl_host; then
			sm_meta="$sm_meta $G_SEP musl"
		else
			sm_meta="$sm_meta $G_SEP glibc"
		fi
	fi
	printf '%s' "$sm_meta"
}

section() { printf '\n  %s%s%s\n' "$C_BOLD" "$*" "$C_RESET"; }
step() { printf '    %s%s %s%s\n' "$C_DIM" "$G_STEP" "$C_RESET" "$*"; }
info() { printf '    %s\n' "$*"; }
dim() { printf '    %s%s%s\n' "$C_DIM" "$*" "$C_RESET"; }
hint() { printf '    %s%s %s%s\n' "$C_DIM" "$G_ARR" "$*" "$C_RESET"; }
ok() { printf '    %s%s %s%s\n' "$C_GRN" "$G_OK" "$C_RESET" "$*"; }
done_() { printf '    %s%s %s%s\n' "$C_GRN" "$G_DONE" "$C_RESET" "$*"; }
warn() { printf '    %s%s %s%s\n' "$C_YEL" "$G_WARN" "$C_RESET" "$*" >&2; }
err() {
	printf '\n  %s%s %s%s\n' "$C_RED" "$G_ERR" "$*" "$C_RESET" >&2
	exit 1
}

usage() {
	cat <<EOF
rfetch installer

on nixos the install goes through your nix profile (nix profile add), everywhere
else the script takes a prebuilt release binary when it runs on this system and
compiles rfetch from source when it does not. it makes that call by itself.

usage: install.sh [options]

options:
  -v, --version <tag>  install a specific release    (default: $REQUESTED_VERSION)
      --prefix <dir>   installation prefix         (default: $PREFIX)
      --dir <path>     where the binary goes        (default: <prefix>/bin/$BIN_NAME)
      --user           install into ~/.local/bin, no root needed
  -m, --musl           build a static musl binary
      --uninstall      remove the installed $BIN_NAME binary
      --no-deps        never install packages, only check for them
  -y, --yes            do not ask for confirmation
      --no-color       plain output, also honours NO_COLOR
      --ascii          ascii only, for terminals without unicode
  -h, --help           show this help

environment:
  RFETCH_VERSION  RFETCH_REPO  RFETCH_PREFIX  RFETCH_DIR  RFETCH_BIN  NO_COLOR
EOF
}

cleanup() {
	if [ -n "$TMPDIR_RF" ] && [ -d "$TMPDIR_RF" ]; then
		rm -rf "$TMPDIR_RF"
	fi
}
trap cleanup 0 INT TERM

# ------------------------------------------------------------- utilities ----

need_cmd() {
	command -v "$1" >/dev/null 2>&1 || err "$2 (missing command: $1)"
}

is_root() { [ "$(id -u)" -eq 0 ]; }

has_sudo() {
	if is_root; then
		return 0
	fi
	for hs_tool in sudo doas runuser; do
		if command -v "$hs_tool" >/dev/null 2>&1; then
			return 0
		fi
	done
	if [ -x /bin/su ]; then
		return 0
	fi
	return 1
}

shquote() {
	printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

as_root() {
	if is_root; then
		"$@"
	elif command -v sudo >/dev/null 2>&1; then
		sudo "$@"
	elif command -v doas >/dev/null 2>&1; then
		doas "$@"
	elif command -v runuser >/dev/null 2>&1; then
		runuser -u root -- "$@"
	elif [ -x /bin/su ]; then
		ar_quoted=""
		for ar_a in "$@"; do
			ar_quoted="$ar_quoted $(shquote "$ar_a")"
		done
		/bin/su -c "$ar_quoted" root
	else
		err "root privileges are required but no sudo, doas or su was found
      try again with --user to install into ~/.local/bin"
	fi
}

# installing packages through the detected manager, as_root everywhere except
# homebrew, which refuses to run under sudo or doas.
install_packages() {
	if [ "$PKG_MANAGER" = brew ]; then
		sh -c "$PKG_INSTALL $*"
	else
		as_root sh -c "$PKG_INSTALL $*"
	fi
}

# `curl | sh` leaves stdin occupied by the installer itself, so a prompt has to
# come from the terminal instead of stdin, or everything would be assumed yes.
confirm() {
	if [ "$ASSUME_YES" -eq 1 ]; then
		return 0
	fi
	if [ -t 0 ]; then
		cf_from="stdin"
	elif [ -t 1 ]; then
		cf_from="tty"
	else
		dim "not a terminal, assuming yes: $*"
		return 0
	fi
	printf '    %s?%s %s [y/N] %s' "$C_YEL" "$C_RESET" "$*" "$C_RESET"
	cf_ans=""
	if [ "$cf_from" = tty ]; then
		if ! { read -r cf_ans </dev/tty; } 2>/dev/null; then
			dim "no terminal to answer, assuming yes: $*"
			return 0
		fi
	elif ! read -r cf_ans; then
		dim "not a terminal, assuming yes: $*"
		return 0
	fi
	case "$cf_ans" in
	y | Y | yes | YES | Yes) return 0 ;;
	*) return 1 ;;
	esac
}

setup_downloader() {
	if command -v curl >/dev/null 2>&1; then
		DOWNLOADER="curl"
	elif command -v wget >/dev/null 2>&1; then
		DOWNLOADER="wget"
	else
		err "neither curl nor wget was found, install one of them and retry."
	fi
}

fetch() {
	if [ "$DOWNLOADER" = curl ]; then
		curl -fsSL --retry 3 -o "$2" "$1"
	else
		wget -q -O "$2" "$1"
	fi
}

fetch_stdout() {
	if [ "$DOWNLOADER" = curl ]; then
		curl -fsSL --retry 3 "$1"
	else
		wget -q -O - "$1"
	fi
}

# -------------------------------------------------------- system details ----

os_field() {
	[ -r /etc/os-release ] || return 0
	# shellcheck disable=SC1091
	. /etc/os-release
	eval "printf '%s' \"\${$1:-}\""
}

PKG_MANAGER=""
PKG_INSTALL=""
PKG_UPDATE=""

detect_pkg_manager() {
	if command -v apt-get >/dev/null 2>&1; then
		PKG_MANAGER="apt"
		PKG_INSTALL="apt-get install -y"
		PKG_UPDATE="apt-get update"
	elif command -v dnf >/dev/null 2>&1; then
		PKG_MANAGER="dnf"
		PKG_INSTALL="dnf install -y"
	elif command -v yum >/dev/null 2>&1; then
		PKG_MANAGER="yum"
		PKG_INSTALL="yum install -y"
	elif command -v zypper >/dev/null 2>&1; then
		PKG_MANAGER="zypper"
		PKG_INSTALL="zypper --non-interactive install"
	elif command -v pacman >/dev/null 2>&1; then
		PKG_MANAGER="pacman"
		PKG_INSTALL="pacman -S --needed --noconfirm"
	elif command -v apk >/dev/null 2>&1; then
		PKG_MANAGER="apk"
		PKG_INSTALL="apk add"
		PKG_UPDATE="apk update"
	elif command -v xbps-install >/dev/null 2>&1; then
		PKG_MANAGER="xbps"
		PKG_INSTALL="xbps-install -y"
		PKG_UPDATE="xbps-install -S"
	elif command -v emerge >/dev/null 2>&1; then
		PKG_MANAGER="portage"
		PKG_INSTALL="emerge --noreplace"
	elif command -v eopkg >/dev/null 2>&1; then
		PKG_MANAGER="eopkg"
		PKG_INSTALL="eopkg install -y"
	elif command -v brew >/dev/null 2>&1; then
		PKG_MANAGER="brew"
		PKG_INSTALL="brew install"
	elif command -v pkg >/dev/null 2>&1; then
		PKG_MANAGER="freebsd"
		PKG_INSTALL="pkg install -y"
		PKG_UPDATE="pkg update"
	elif command -v pkgin >/dev/null 2>&1; then
		PKG_MANAGER="pkgin"
		PKG_INSTALL="pkgin -y install"
		PKG_UPDATE="pkgin update"
	elif command -v nix >/dev/null 2>&1; then
		PKG_MANAGER="nix"
	else
		PKG_MANAGER="unknown"
	fi
}

deps_for() {
	case "$PKG_MANAGER" in
	apt) printf '%s' "build-essential curl ca-certificates tar" ;;
	dnf | yum) printf '%s' "gcc make curl ca-certificates tar" ;;
	zypper) printf '%s' "gcc make curl ca-certificates tar" ;;
	pacman) printf '%s' "base-devel curl ca-certificates tar" ;;
	apk) printf '%s' "build-base curl ca-certificates tar" ;;
	xbps) printf '%s' "base-devel curl ca-certificates tar" ;;
	portage) printf '%s' "curl ca-certificates tar" ;;
	eopkg) printf '%s' "gcc curl ca-certificates tar" ;;
	brew) printf '%s' "curl tar" ;;
	freebsd) printf '%s' "curl ca-certificates gtar" ;;
	pkgin) printf '%s' "curl ca-certificates gtar" ;;
	*) printf '%s' "curl ca-certificates tar" ;;
	esac
}

have_cc() {
	for hc_cc in cc gcc clang; do
		if command -v "$hc_cc" >/dev/null 2>&1; then
			return 0
		fi
	done
	return 1
}

have_cargo() {
	if command -v cargo >/dev/null 2>&1; then
		return 0
	fi
	if [ -x "$HOME/.cargo/bin/cargo" ]; then
		PATH="$HOME/.cargo/bin:$PATH"
		export PATH
		return 0
	fi
	return 1
}

install_deps() {
	if [ "$PKG_MANAGER" = unknown ]; then
		warn "unknown package manager, cannot install build dependencies for you."
		info "you will need: curl, ca-certificates, tar and a C compiler."
		return 0
	fi
	if [ "$PKG_MANAGER" = nix ]; then
		nd_missing=""
		command -v curl >/dev/null 2>&1 || nd_missing="$nd_missing curl"
		command -v tar >/dev/null 2>&1 || nd_missing="$nd_missing tar"
		have_cc || nd_missing="$nd_missing a-c-compiler"
		if [ -n "$nd_missing" ]; then
			warn "nix manages packages, so these have to come from your config:$nd_missing"
			info "home-manager: programs.curl / packages = with pkgs; [ curl ca-certificates tar gcc ];"
		else
			ok "build dependencies are present"
		fi
		return 0
	fi

	id_missing=""
	command -v curl >/dev/null 2>&1 || id_missing="$id_missing curl"
	command -v tar >/dev/null 2>&1 || command -v gtar >/dev/null 2>&1 || id_missing="$id_missing tar"
	have_cc || id_missing="$id_missing a-c-compiler"

	if [ -z "$id_missing" ]; then
		ok "build dependencies are present"
		return 0
	fi

	info "missing:$id_missing"
	if [ "$NO_DEPS" -eq 1 ]; then
		err "--no-deps was given but these are required:$id_missing"
	fi
	confirm "install them with $PKG_MANAGER?" || err "aborted."
	if [ -n "$PKG_UPDATE" ]; then
		dim "updating the package lists"
		as_root sh -c "$PKG_UPDATE" >/dev/null 2>&1 ||
			warn "package list update failed, continuing anyway"
	fi
	install_packages "$(deps_for)" || err "dependency installation failed."
	have_cc || err "no C compiler available after installing dependencies, install one manually."
	ok "dependencies installed"
}

# ------------------------------------------------------------ rust setup ----

setup_rust() {
	if have_cargo; then
		report_cargo
		return 0
	fi
	if [ -r "$HOME/.cargo/env" ]; then
		# shellcheck disable=SC1091
		. "$HOME/.cargo/env"
		if have_cargo; then
			report_cargo
			return 0
		fi
	fi
	if [ "$NO_DEPS" -eq 1 ]; then
		err "cargo was not found and --no-deps was given."
	fi

	warn "no rust toolchain found"
	if [ "$PKG_MANAGER" = nix ]; then
		info "the nix way to get cargo: nix profile add nixpkgs#cargo"
		if confirm "run it now?" && nix profile add nixpkgs#cargo && have_cargo; then
			report_cargo
			return 0
		fi
		warn "falling back to rustup, which works but is not the nix way"
	fi
	info "it will be installed through rustup into $HOME/.cargo"
	confirm "install rustup now?" || err "aborted. install rust from https://rustup.rs and retry."
	fetch "https://sh.rustup.rs" "$TMPDIR_RF/rustup-init.sh"
	sh "$TMPDIR_RF/rustup-init.sh" -y --no-modify-path --profile minimal ||
		err "rustup installation failed."
	have_cargo || err "cargo is still missing after installing rustup."
	report_cargo
}

report_cargo() {
	rc_ver=$(cargo --version 2>/dev/null | head -n1)
	if [ -n "$rc_ver" ]; then
		ok "$rc_ver"
	else
		ok "cargo found, but it did not report a version"
	fi
}

# ------------------------------------------------------ platform details ----

KERNEL="$(uname -s)"
MACHINE="$(uname -m)"

case "$MACHINE" in
x86_64 | amd64) ARCH=x86_64 ;;
aarch64 | arm64) ARCH=aarch64 ;;
armv7l | armv7) ARCH=armv7 ;;
armv6l | armv6) ARCH=armv6 ;;
i386 | i486 | i586 | i686) ARCH=i686 ;;
*) ARCH="$MACHINE" ;;
esac

asset_candidates() {
	case "$1" in
	gnu) printf '%s\n' \
		"rfetch-$ARCH-unknown-linux-gnu" \
		"rfetch-$ARCH-gnu-linux" \
		"rfetch-$ARCH-gnu" \
		"rfetch-$ARCH-linux" ;;
	musl) printf '%s\n' \
		"rfetch-$ARCH-unknown-linux-musl" \
		"rfetch-$ARCH-musl" ;;
	esac
}

is_musl_host() {
	if ldd --version 2>&1 | grep -qi musl; then
		return 0
	fi
	if command -v apk >/dev/null 2>&1; then
		return 0
	fi
	return 1
}

# -------------------------------------------------------- version lookup ----

resolve_tag() {
	case "$1" in
	latest)
		rt_body=$(fetch_stdout "https://api.github.com/repos/$REPO/releases/latest" 2>/dev/null || true)
		TAG=$(printf '%s' "$rt_body" |
			sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
			head -n1)
		[ -n "$TAG" ] || TAG="HEAD"
		;;
	v*) TAG="$1" ;;
	*) TAG="v$1" ;;
	esac
}

# -------------------------------------------------------------- download ----

git_clone() {
	need_cmd git "git is required to fetch the source code."
	dim "cloning $REPO ($TAG)"
	if [ "$TAG" = HEAD ]; then
		git clone --depth 1 "https://github.com/$REPO.git" "$TMPDIR_RF/src/rfetch" ||
			err "git clone failed."
	else
		git clone --depth 1 --branch "$TAG" "https://github.com/$REPO.git" \
			"$TMPDIR_RF/src/rfetch" || err "git clone failed."
	fi
}

extract_tarball() {
	if tar -xzf "$TMPDIR_RF/src.tar.gz" -C "$TMPDIR_RF/src" 2>/dev/null; then
		:
	elif command -v gzip >/dev/null 2>&1 &&
		gzip -dc "$TMPDIR_RF/src.tar.gz" | tar -xf - -C "$TMPDIR_RF/src" 2>/dev/null; then
		:
	else
		return 1
	fi
	for gs_entry in "$TMPDIR_RF"/src/*; do
		[ -f "$gs_entry/Cargo.toml" ] || continue
		mv "$gs_entry" "$TMPDIR_RF/src/rfetch"
		return 0
	done
	return 1
}

get_source_dir() {
	gs_dest=$1
	rm -rf "$TMPDIR_RF/src"
	mkdir -p "$TMPDIR_RF/src"

	if [ "$TAG" != HEAD ]; then
		step "downloading the source of $TAG"
		if fetch "https://codeload.github.com/$REPO/tar.gz/refs/tags/$TAG" \
			"$TMPDIR_RF/src.tar.gz" 2>/dev/null; then
			if ! extract_tarball; then
				warn "could not unpack the source tarball, falling back to git"
			fi
		fi
	fi

	if [ ! -f "$TMPDIR_RF/src/rfetch/Cargo.toml" ]; then
		rm -rf "$TMPDIR_RF/src"
		mkdir -p "$TMPDIR_RF/src"
		git_clone
	fi

	cp -R "$TMPDIR_RF/src/rfetch" "$gs_dest"
}

sha256_of() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum <"$1" | cut -d' ' -f1
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 <"$1" | cut -d' ' -f1
	elif command -v openssl >/dev/null 2>&1; then
		openssl dgst -sha256 <"$1" | sed 's/.*=[[:space:]]*//'
	elif cksum -a sha256 </dev/null >/dev/null 2>&1; then
		cksum -a sha256 <"$1" | cut -d' ' -f1
	fi
}

verify_checksum() {
	vc_url=$1
	vc_bin=$2
	vc_name=$3
	if ! fetch "$vc_url.sha256" "$vc_bin.sha256" 2>/dev/null; then
		dim "no published checksum, skipping verification"
		return 0
	fi
	vc_expected=$(head -n1 "$vc_bin.sha256" | tr -d '\r' | cut -d' ' -f1)
	rm -f "$vc_bin.sha256"
	vc_actual=$(sha256_of "$vc_bin")
	if [ -z "$vc_actual" ]; then
		warn "no sha256 utility found, cannot verify $vc_name"
		return 0
	fi
	if [ -z "$vc_expected" ] || [ "$vc_expected" != "$vc_actual" ]; then
		err "checksum mismatch for $vc_name
      expected ${vc_expected:-none}
      actual   $vc_actual"
	fi
	ok "checksum verified"
}

get_prebuilt() {
	gp_out=$1
	if [ "$KERNEL" != Linux ]; then
		return 1
	fi
	if [ "$USE_MUSL" -eq 1 ] || is_musl_host; then
		gp_flavour=musl
	else
		gp_flavour=gnu
	fi
	step "looking for a prebuilt $gp_flavour binary for $ARCH"
	for gp_name in $(asset_candidates "$gp_flavour"); do
		gp_url="https://github.com/$REPO/releases/download/$TAG/$gp_name"
		if fetch "$gp_url" "$gp_out" 2>/dev/null; then
			verify_checksum "$gp_url" "$gp_out" "$gp_name" || return 1
			chmod +x "$gp_out"
			PREBUILT_NAME="$gp_name"
			return 0
		fi
	done
	return 1
}

# an asset is only worth installing when it actually runs on this machine,
# releases can be linked against libraries this system does not ship.
prebuilt_runs() {
	pb_code=0
	pb_out=$("$1" --version 2>&1) || pb_code=$?
	pb_head=$(printf '%s\n' "$pb_out" | head -n1)
	if [ "$pb_code" -eq 0 ] && [ "${pb_head#rfetch v}" != "$pb_head" ]; then
		return 0
	fi
	if [ -n "$pb_head" ]; then
		pb_diag=$pb_head
	else
		pb_diag="it exited with status $pb_code"
	fi
	return 1
}

# ----------------------------------------------------------------- build ----

# releases up to v1.0.0 link against libdrm while compiling, newer ones only
# read its data files at runtime, so the unpacked source decides if it is needed.
ensure_link_libs() {
	[ "$KERNEL" = Linux ] || return 0
	have_cc || return 0
	eld_src=$1
	eld_needed=0
	for eld_file in "$eld_src/Cargo.toml" "$eld_src/Cargo.lock"; do
		[ -f "$eld_file" ] || continue
		if grep -qi -e libdrm -e gfxinfo "$eld_file"; then
			eld_needed=1
			break
		fi
	done
	[ "$eld_needed" -eq 1 ] || return 0
	if printf 'int main(void){return 0;}\n' | cc -x c - -o /dev/null \
		-ldrm -ldrm_amdgpu 2>/dev/null; then
		return 0
	fi
	if [ "$PKG_MANAGER" = nix ]; then
		err "this release links against libdrm, which this system does not have.
      home-manager: packages = with pkgs; [ libdrm ];
      newer releases do not need it, drop --version to get one"
	fi
	case "$PKG_MANAGER" in
	apt) eld_pkg="libdrm-dev" ;;
	dnf | yum | zypper | xbps) eld_pkg="libdrm-devel" ;;
	pacman | apk | freebsd | pkgin | brew) eld_pkg="libdrm" ;;
	portage) eld_pkg="media-libs/libdrm" ;;
	*) eld_pkg="" ;;
	esac
	if [ -z "$eld_pkg" ]; then
		err "this release links against libdrm, which is missing here.
      install it (libdrm-dev or libdrm-devel) and run this again"
	fi
	if [ "$NO_DEPS" -eq 1 ]; then
		err "this release links against libdrm and --no-deps was given.
      install $eld_pkg and run this again"
	fi
	confirm "install $eld_pkg with $PKG_MANAGER?" ||
		err "the build needs libdrm, install $eld_pkg and run this again."
	install_packages "$eld_pkg" || err "could not install $eld_pkg."
	ok "installed $eld_pkg"
}

build_from_source() {
	bs_src=$1
	bs_version=$(sed -n 's/^version[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "$bs_src/Cargo.toml" |
		head -n1)
	step "compiling rfetch ${bs_version:-(from source)}, this can take a while"
	MUSL_TARGET=""

	if [ "$USE_MUSL" -eq 1 ] && ! is_musl_host; then
		if ! command -v musl-gcc >/dev/null 2>&1; then
			info "musl build requested, installing musl tools"
			case "$PKG_MANAGER" in
			apt) as_root sh -c "apt-get install -y musl-tools" || warn "could not install musl-tools" ;;
			apk) as_root sh -c "apk add musl-dev" || warn "could not install musl-dev" ;;
			dnf | yum) as_root sh -c "$PKG_INSTALL musl-gcc" || warn "could not install musl-gcc" ;;
			*) warn "could not install musl tools automatically" ;;
			esac
		fi
		if command -v musl-gcc >/dev/null 2>&1 && command -v rustup >/dev/null 2>&1; then
			dim "adding the $ARCH musl rust target"
			rustup target add "$ARCH-unknown-linux-musl" >/dev/null 2>&1 ||
				warn "could not add the musl target"
			MUSL_TARGET="$ARCH-unknown-linux-musl"
		elif command -v musl-gcc >/dev/null 2>&1; then
			warn "rustup not found, cannot select a cross target, building for the host"
		else
			warn "musl-gcc is missing, building for the host instead"
		fi
	fi

	if [ -n "$MUSL_TARGET" ]; then
		if (cd "$bs_src" && cargo build --release --target "$MUSL_TARGET" --locked) ||
			(cd "$bs_src" && cargo build --release --target "$MUSL_TARGET"); then
			ok "build finished (musl)"
			return 0
		fi
		warn "the musl build failed, falling back to a native build"
	fi

	if (cd "$bs_src" && cargo build --release --locked) ||
		(cd "$bs_src" && cargo build --release); then
		ok "build finished"
		return 0
	fi
	err "the build failed."
}

# --------------------------------------------------------------- install ----

resolve_dest() {
	if [ -n "${RFETCH_DIR:-}" ]; then
		printf '%s' "$RFETCH_DIR"
	elif [ -n "$INSTALL_DIR" ]; then
		printf '%s' "$INSTALL_DIR"
	elif [ "$PKG_MANAGER" = nix ] && [ "$PREFIX" = /usr/local ]; then
		printf '%s' "$HOME/.local/bin/$BIN_NAME"
	else
		printf '%s/bin/%s' "$PREFIX" "$BIN_NAME"
	fi
}

install_binary() {
	ib_src=$1
	ib_dest=$2
	ib_dir=$(dirname "$ib_dest")

	if [ ! -d "$ib_dir" ]; then
		mkdir -p "$ib_dir" 2>/dev/null || true
	fi

	if [ -d "$ib_dir" ] && [ -w "$ib_dir" ]; then
		cp -f "$ib_src" "$ib_dest" || err "could not write to $ib_dest"
		[ -x "$ib_dest" ] || chmod +x "$ib_dest"
	else
		has_sudo || err "cannot write to $ib_dir and no sudo, doas or su was found
      try again with --user to install into ~/.local/bin"
		as_root mkdir -p "$ib_dir"
		as_root cp -f "$ib_src" "$ib_dest"
	fi
	ok "installed to $ib_dest"
}

do_uninstall() {
	du_dest=$1
	if [ -e "$du_dest" ]; then
		if [ -w "$du_dest" ]; then
			rm -f "$du_dest"
		else
			has_sudo || err "cannot remove $du_dest without root privileges."
			as_root rm -f "$du_dest"
		fi
		ok "removed $du_dest"
	else
		info "there is nothing installed at $du_dest"
	fi
	hint "your config in ~/.config/rfetch was left untouched"
}

verify_install() {
	vi_dest=$1
	[ -x "$vi_dest" ] || return 0
	if vi_out=$("$vi_dest" --version 2>/dev/null | head -n1) && [ -n "$vi_out" ]; then
		done_ "$vi_out"
	else
		warn "$vi_dest could not be executed, try running it manually"
	fi
	case ":$PATH:" in
	*":$(dirname "$vi_dest"):"*) ;;
	*) hint "$(dirname "$vi_dest") is not in your PATH, add it with:"
		hint "export PATH=\"$(dirname "$vi_dest"):\$PATH\"" ;;
	esac
}

distro_hint() {
	case "$PKG_MANAGER" in
	pacman) hint "arch users can also install rfetch with paru -S rfetch" ;;
	nix) hint "nix users can skip this script: nix run github:$REPO" ;;
	brew) hint "you can also use: nix run github:$REPO" ;;
	esac
	return 0
}

uninstall_target() {
	if nix_owns_destination; then
		printf 'your nix profile'
	else
		printf '%s' "$(resolve_dest)"
	fi
}

# the nix profile owns the binary unless the user asked for a specific path
nix_owns_destination() {
	if [ "$PKG_MANAGER" != nix ]; then
		return 1
	fi
	if [ -n "$INSTALL_DIR" ] || [ -n "${RFETCH_DIR:-}" ] || [ "$PREFIX" != /usr/local ]; then
		return 1
	fi
	return 0
}

should_use_nix_profile() {
	if ! nix_owns_destination; then
		return 1
	fi
	if [ "$NO_DEPS" -eq 1 ] || [ "$USE_MUSL" -eq 1 ]; then
		return 1
	fi
	return 0
}

nix_profile_ref() {
	case "$REQUESTED_VERSION" in
	latest) printf 'github:%s' "$REPO" ;;
	v*) printf 'github:%s/%s' "$REPO" "$REQUESTED_VERSION" ;;
	*) printf 'github:%s/v%s' "$REPO" "$REQUESTED_VERSION" ;;
	esac
}

install_via_nix_profile() {
	np_ref=$(nix_profile_ref)
	step "nix owns your packages, so this goes through your nix profile"
	dim "nix profile add $np_ref"
	confirm "install it now?" || return 1
	if ! nix profile add "$np_ref"; then
		warn "nix profile add failed"
		return 1
	fi
	ok "added to your nix profile"
	if [ -x "$HOME/.nix-profile/bin/$BIN_NAME" ]; then
		verify_install "$HOME/.nix-profile/bin/$BIN_NAME"
	else
		info "the profile copy should be at $HOME/.nix-profile/bin/$BIN_NAME"
		if command -v "$BIN_NAME" >/dev/null 2>&1; then
			warn "the $BIN_NAME on your PATH comes from $(command -v "$BIN_NAME"), check it is the one you wanted"
		else
			warn "$BIN_NAME is not on your PATH, check your nix profile"
		fi
	fi
	hint "remove it again with: nix profile remove $BIN_NAME"
	return 0
}

# ------------------------------------------------------------------ main ----

main() {
	setup_style
	while [ $# -gt 0 ]; do
		case "$1" in
		-v | --version)
			[ -n "${2:-}" ] || err "--version needs a value"
			REQUESTED_VERSION=$2
			shift 2
			;;
		--prefix)
			[ -n "${2:-}" ] || err "--prefix needs a value"
			PREFIX=$2
			INSTALL_DIR=""
			shift 2
			;;
		--dir)
			[ -n "${2:-}" ] || err "--dir needs a value"
			INSTALL_DIR=$2
			shift 2
			;;
		--user)
			INSTALL_DIR="$HOME/.local/bin/$BIN_NAME"
			shift
			;;
		-m | --musl)
			USE_MUSL=1
			shift
			;;
		--uninstall)
			UNINSTALL=1
			shift
			;;
		--no-deps)
			NO_DEPS=1
			shift
			;;
		-y | --yes)
			ASSUME_YES=1
			shift
			;;
		--no-color)
			NO_COLOR=1
			PLAIN=1
			shift
			;;
		--ascii)
			PLAIN=1
			NO_COLOR="${NO_COLOR:-}"
			shift
			;;
		-h | --help)
			usage
			exit 0
			;;
		*) err "unknown option: $1 (see --help)" ;;
		esac
	done

	setup_style

	TMPDIR_RF=$(mktemp -d 2>/dev/null || mktemp -d -t rfetch)

	detect_pkg_manager
	mn_dest=$(resolve_dest)

	if [ "$UNINSTALL" -eq 1 ]; then
		banner "removing $BIN_NAME from $(uninstall_target)"
		if nix_owns_destination; then
			if nix profile remove "$BIN_NAME" >/dev/null 2>&1; then
				ok "$BIN_NAME is gone from your nix profile"
			else
				info "$BIN_NAME was not in your nix profile"
			fi
			hint "your config in ~/.config/rfetch was left untouched"
			return 0
		fi
		do_uninstall "$mn_dest"
		return 0
	fi

	banner "$(sys_meta)"
	distro_hint

	if should_use_nix_profile; then
		if install_via_nix_profile; then
			return 0
		fi
		warn "falling back to a local install"
	fi

	if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
		if [ "$NO_DEPS" -eq 1 ]; then
			err "neither curl nor wget is available and --no-deps was given."
		fi
		case "$PKG_MANAGER" in
		nix | unknown)
			err "neither curl nor wget is available. on nix: add programs.curl to your config."
			;;
		*)
			confirm "install curl with $PKG_MANAGER?" ||
				err "aborted. install curl or wget first."
			install_packages curl || err "could not install curl."
			;;
		esac
	fi
	setup_downloader

	resolve_tag "$REQUESTED_VERSION"
	if [ "$TAG" != HEAD ]; then
		step "version $TAG"
	fi

	mn_bin="$TMPDIR_RF/$BIN_NAME"
	if get_prebuilt "$mn_bin"; then
		if prebuilt_runs "$mn_bin"; then
			section "prebuilt binary"
			ok "downloaded $PREBUILT_NAME"
			section "install"
			install_binary "$mn_bin" "$mn_dest"
			verify_install "$mn_dest"
			return 0
		fi
		warn "the prebuilt $PREBUILT_NAME does not run on this system"
		hint "${pb_diag:-it was linked against libraries you do not have}"
	elif [ "$KERNEL" = Linux ]; then
		if [ "$TAG" = HEAD ]; then
			dim "a source snapshot, no release asset to look for"
		else
			warn "release $TAG has no prebuilt binary for $ARCH/$KERNEL"
		fi
	fi
	rm -f "$mn_bin"
	dim "compiling $BIN_NAME from source instead"

	section "dependencies"
	install_deps
	section "toolchain"
	setup_rust
	section "build"
	mn_src="$TMPDIR_RF/build"
	get_source_dir "$mn_src"
	ensure_link_libs "$mn_src"
	build_from_source "$mn_src"
	section "install"
	install_binary "$mn_src/target/release/$BIN_NAME" "$mn_dest"
	verify_install "$mn_dest"
}

main "$@"
