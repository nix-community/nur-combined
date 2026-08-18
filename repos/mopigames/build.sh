#!/usr/bin/env bash
# Build the Moonlight OS ISO.
#
# live-build needs a Debian host and root privileges, so the whole build runs
# inside a privileged Debian container.  Nothing is installed on your machine.
#
#   ./build.sh                 build the ISO
#   ./build.sh clean           throw away build artifacts, keep the download cache
#   ./build.sh shell           drop into the build container to poke around
#
# Environment:
#   SELENE_SRC=<path>          Selene checkout to build the client from
#                              (default ~/moonlight-os-stuff/selene)
#   SELENE_REBUILD=1           rebuild the Selene .deb even if one is staged
#   FIRMWARE=full|slim         slim drops ~400 MB of firmware blobs
#   TAILSCALE_VERSION=1.2.3    pin Tailscale; default is the current stable
#   SSH_KEYS=auto|none|<path>  which public keys may log in over SSH.
#                              auto takes ~/.ssh/*.pub from this machine.
#   MLOS_SUITE=trixie          Debian release to base on
#   HOST_UTILS=amd64|all|none  which mlos-host-utils builds to carry
#                              on the ISO for copying to the host PC
#   INCREMENTAL=1              reuse the existing chroot (fast, but silently
#                              ignores any config change -- debugging only)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE=moonlight-os-builder
# Stamped into the ISO filename. It used to select which Moonlight AppImage to
# download; the client is now built from source, so it is only a label.
ISO_VERSION="${ISO_VERSION:-6.1.0}"
FIRMWARE="${FIRMWARE:-full}"
MLOS_SUITE="${MLOS_SUITE:-trixie}"
TAILSCALE_VERSION="${TAILSCALE_VERSION:-}"
SSH_KEYS="${SSH_KEYS:-auto}"
HOST_UTILS="${HOST_UTILS:-amd64}"
GO_IMAGE="${GO_IMAGE:-golang:1.24-bookworm}"
# Used when pkgs.tailscale.com cannot be reached to ask what stable is.
TAILSCALE_FALLBACK=1.102.2

SELENE_SRC="${SELENE_SRC:-$HOME/moonlight-os-stuff/selene}"

say() { printf '\033[1;35m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

command -v docker >/dev/null || die "docker is required to build the image."
docker info >/dev/null 2>&1 || die "cannot talk to the docker daemon."

# ---------------------------------------------------------------- builder ---
build_builder_image() {
	say "Preparing the build container"
	docker build -q --network host -t "$IMAGE" - >/dev/null <<-DOCKERFILE
	FROM debian:${MLOS_SUITE}
	ENV DEBIAN_FRONTEND=noninteractive
	RUN sed -i 's/^Components:.*/Components: main contrib non-free non-free-firmware/' \
	        /etc/apt/sources.list.d/debian.sources \
	 && apt-get update \
	 && apt-get install -y --no-install-recommends \
	        live-build debootstrap xorriso squashfs-tools \
	        syslinux syslinux-common isolinux \
	        grub-efi-amd64-bin grub-common mtools dosfstools \
	        ca-certificates curl file rsync \
	 && rm -rf /var/lib/apt/lists/*
	DOCKERFILE
}

# ---------------------------------------------------------------- selene ----
# Selene is built from source as a real Debian package and dropped into
# config/packages.chroot/, where live-build installs it into the image like any
# other package.  That is what lets the client use the image's own Qt, SDL,
# FFmpeg and VA-API rather than carrying a second copy of all of them, and it
# is why the LIBVA_DRIVERS_PATH override and the "pkill -x AppRun" fallback are
# both gone from the launcher scripts.
fetch_selene() {
	[[ -d "$SELENE_SRC" ]] \
		|| die "Selene source not found at $SELENE_SRC. Set SELENE_SRC to the checkout."

	# Working copies from before the switch still have the extracted AppImage
	# sitting in the image tree.  live-build copies whatever is there, so
	# without this the ISO quietly ships a dead 145 MB copy of the old client
	# alongside the new package.  Ignoring it in git is not enough -- git
	# ignores it, live-build does not.
	if [[ -d "$HERE/config/includes.chroot/opt/moonlight" ]]; then
		say "Removing the superseded Moonlight AppImage from the image tree"
		rm -rf "$HERE/config/includes.chroot/opt/moonlight"
	fi

	local dest="$HERE/config/packages.chroot"
	mkdir -p "$dest"

	if [[ -z "${SELENE_REBUILD:-}" ]] && compgen -G "$dest/selene_*.deb" >/dev/null; then
		say "Using the Selene package already staged in packages.chroot"
		return
	fi

	say "Building the Selene package from $SELENE_SRC"
	# build-deb.sh does its work in a Debian container of the same suite, so
	# the package matches the image regardless of what this machine runs.
	MLOS_SUITE="$MLOS_SUITE" "$SELENE_SRC/scripts/build-deb.sh" \
		|| die "Selene package build failed"

	rm -f "$dest"/selene_*.deb
	cp "$SELENE_SRC"/dist/selene_*.deb "$dest/" \
		|| die "no Selene .deb was produced"
	say "Staged $(basename "$(ls -1 "$dest"/selene_*.deb | head -1)")"
}

# ------------------------------------------------------------- tailscale ----
# Tailscale is not in Debian, and its apt repo would mean shipping and
# trusting a signing key at build time.  The official static tarball is
# simpler and pins an exact version.
fetch_tailscale() {
	mkdir -p "$HERE/cache"

	if [[ -z "$TAILSCALE_VERSION" ]]; then
		say "Looking up the current Tailscale release"
		TAILSCALE_VERSION="$(curl -fsSL 'https://pkgs.tailscale.com/stable/?mode=json' 2>/dev/null \
			| tr ',' '\n' \
			| sed -n 's/.*"TarballsVersion": *"\([^"]*\)".*/\1/p' | head -1)"
		[[ -n "$TAILSCALE_VERSION" ]] || TAILSCALE_VERSION="$TAILSCALE_FALLBACK"
	fi

	local tgz="tailscale_${TAILSCALE_VERSION}_amd64.tgz"
	local url="https://pkgs.tailscale.com/stable/$tgz"

	if [[ ! -f "$HERE/cache/$tgz" ]]; then
		say "Downloading Tailscale $TAILSCALE_VERSION"
		curl -fL --progress-bar -o "$HERE/cache/$tgz.part" "$url" \
			|| die "could not download $url"
		mv "$HERE/cache/$tgz.part" "$HERE/cache/$tgz"
	else
		say "Using cached Tailscale $TAILSCALE_VERSION"
	fi

	local stamp="$HERE/config/includes.chroot/usr/bin/.tailscale-version"
	if [[ -f "$stamp" ]] && [[ "$(cat "$stamp")" == "$TAILSCALE_VERSION" ]]; then
		return
	fi

	say "Unpacking Tailscale into the image tree"
	# Unpacked in the container so the files land root-owned, like the rest
	# of the image, rather than owned by whoever ran the build.
	docker run --rm --network host \
		-v "$HERE/cache:/cache:ro" \
		-v "$HERE/config/includes.chroot:/dest" \
		"$IMAGE" bash -euc "
			cd /tmp
			tar xzf /cache/$tgz
			src=tailscale_${TAILSCALE_VERSION}_amd64
			install -D -m 0755 \$src/tailscale  /dest/usr/bin/tailscale
			install -D -m 0755 \$src/tailscaled /dest/usr/sbin/tailscaled
			install -D -m 0644 \$src/systemd/tailscaled.service \
				/dest/etc/systemd/system/tailscaled.service
			install -D -m 0644 \$src/systemd/tailscaled.defaults \
				/dest/etc/default/tailscaled
			echo '$TAILSCALE_VERSION' > /dest/usr/bin/.tailscale-version
		" || die "could not unpack Tailscale"
}

# ------------------------------------------------------- host utils --------
# The host PC half of USB passthrough, carried on the ISO so there is
# something to copy across without a second machine and a browser.  The USB
# passthrough menu prints the scp line that fetches it.
#
# amd64 is the default because a host PC is one, and shipping the arm64
# builds as well doubles this for a case nobody has yet.
build_host_utils() {
	local dest="$HERE/config/includes.chroot/opt/mlos-host-utils"
	rm -rf "$dest"

	if [[ "$HOST_UTILS" == "none" ]]; then
		say "Host utils: not carrying them on the ISO"
		return
	fi

	local targets="linux/amd64 windows/amd64"
	[[ "$HOST_UTILS" == "all" ]] && targets="linux/amd64 linux/arm64 windows/amd64 windows/arm64"

	local version
	version="$(date +%Y.%m.%d)"

	say "Building mlos-host-utils $version ($HOST_UTILS)"
	mkdir -p "$dest" "$HERE/cache/go-build" "$HERE/cache/go-mod"

	# Built in the container so the toolchain is not a requirement for
	# building the ISO, and so the binaries are reproducible across the
	# machines people build this on.  Caches are kept in cache/ alongside
	# the .debs, so a rebuild is quick and `clean` leaves them alone.
	docker run --rm --network host \
		-v "$HERE/host-utils:/src:ro" \
		-v "$dest:/out" \
		-v "$HERE/cache/go-build:/gocache" \
		-v "$HERE/cache/go-mod:/gomod" \
		-e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
		-e GOCACHE=/gocache -e GOMODCACHE=/gomod \
		-e CGO_ENABLED=0 \
		-w /src \
		"$GO_IMAGE" bash -euc "
			go vet ./...
			go test ./...
			for t in $targets; do
				os=\${t%/*}; arch=\${t#*/}
				name=mlos-host-utils-\$os-\$arch
				[ \"\$os\" = windows ] && name=\$name.exe
				GOOS=\$os GOARCH=\$arch go build -trimpath \
					-ldflags '-s -w -X main.Version=$version' \
					-o /out/\$name .
			done
			cp README.md /out/README.md
			chmod -R a+rX /out
			chown -R \$HOST_UID:\$HOST_GID /out
		" || die "could not build mlos-host-utils"

	say "Host utils: $(du -sh "$dest" | cut -f1) staged for the ISO"
}

# ------------------------------------------------------------- ssh keys ----
# Password logins are off in the image, so whatever lands here is the only
# way in over the network.  Staged root-side of the home directory; the user
# hook installs it with the ownership and mode sshd insists on.
stage_ssh_keys() {
	local dest="$HERE/config/includes.chroot/etc/moonlight-os/authorized_keys"
	rm -f "$dest"

	case "$SSH_KEYS" in
		none)
			say "SSH: no keys staged (remote login will be impossible until you set a password on the box)"
			return
			;;
		auto)
			local found=()
			local k
			for k in "$HOME"/.ssh/*.pub; do
				[[ -f "$k" ]] && found+=("$k")
			done
			if [[ ${#found[@]} -eq 0 ]]; then
				say "SSH: no public key found in ~/.ssh -- nobody will be able to log in remotely"
				say "     (make one with 'ssh-keygen', or build with SSH_KEYS=none to silence this)"
				return
			fi
			cat "${found[@]}" > "$dest"
			;;
		*)
			[[ -f "$SSH_KEYS" ]] || die "SSH_KEYS=$SSH_KEYS is not a file."
			cat "$SSH_KEYS" > "$dest"
			;;
	esac

	chmod 0644 "$dest"
	say "SSH: $(grep -c . "$dest") key(s) authorised for the moonlight user"
	while read -r line; do
		[[ -n "$line" ]] && printf '      %s\n' "$line"
	done < <(ssh-keygen -lf "$dest" 2>/dev/null || true)
}

# ----------------------------------------------------------------- build ----
do_build() {
	build_builder_image
	fetch_selene
	fetch_tailscale
	build_host_utils
	stage_ssh_keys

	local pkglist="config/package-lists/moonlight-os.list.chroot"
	if [[ "$FIRMWARE" == "slim" ]]; then
		say "Firmware: slim (dropping the large blob packages)"
	fi
	say "Running live-build (this takes a while and downloads ~1 GB)"
	# live-build must run as root; hand ownership back afterwards either way
	# so the project directory stays usable from your normal account.
	docker run --rm --privileged --network host \
		-v "$HERE:/build" \
		-e MLOS_SUITE="$MLOS_SUITE" \
		-e FIRMWARE="$FIRMWARE" \
		-e HOST_UID="$(id -u)" -e INCREMENTAL="${INCREMENTAL:-0}" \
		-e HOST_GID="$(id -g)" \
		-w /build \
		"$IMAGE" bash -uc '
			set -e
			finish() { chown -R "$HOST_UID:$HOST_GID" /build 2>/dev/null || true; }
			trap finish EXIT
			if [ "$FIRMWARE" = "slim" ]; then
				sed -i "s/^firmware-linux$/#firmware-linux/;
				        s/^firmware-misc-nonfree$/#firmware-misc-nonfree/" \
				    '"$pkglist"'
			fi
			# lb build is incremental: it skips any stage whose stamp in
			# .build/ already exists, so a second run silently ignores every
			# config change and reuses the old chroot.  Always clear the
			# stamps first.  This keeps cache/ (only --purge drops that), so
			# the rebuild reuses downloaded .debs and stays quick.
			if [ "${INCREMENTAL:-0}" != "1" ]; then
				lb clean >/dev/null 2>&1 || true
			fi
			lb config
			lb build
		' || die "live-build failed (see the output above)"

	# Those are local mutations of a tracked file; undo them.
	if [[ "$FIRMWARE" == "slim" ]]; then
		sed -i 's/^#firmware-linux$/firmware-linux/; s/^#firmware-misc-nonfree$/firmware-misc-nonfree/' \
			"$HERE/$pkglist"
	fi
	mkdir -p "$HERE/out"
	local iso
	iso="$(find "$HERE" -maxdepth 1 -name "moonlight-os*.iso" -print -quit)"
	[[ -n "$iso" ]] || die "the build finished but produced no ISO."

	local stamp
	stamp="$(date +%Y%m%d)"
	mv "$iso" "$HERE/out/moonlight-os-${ISO_VERSION}-${stamp}.iso"

	say "Done: out/moonlight-os-${ISO_VERSION}-${stamp}.iso ($(du -h "$HERE/out/moonlight-os-${ISO_VERSION}-${stamp}.iso" | cut -f1))"
	printf '\nWrite it to a USB stick with:\n  sudo dd if=out/moonlight-os-%s-%s.iso of=/dev/sdX bs=4M status=progress oflag=sync\n\n' \
		"$ISO_VERSION" "$stamp"
}

do_clean() {
	build_builder_image
	say "Cleaning build artifacts"
	docker run --rm --privileged --network host -v "$HERE:/build" -w /build \
		-e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
		"$IMAGE" bash -uc 'lb clean --purge || true
			chown -R "$HOST_UID:$HOST_GID" /build 2>/dev/null || true' || true
	rm -rf "$HERE/config/includes.chroot/etc/moonlight-os/authorized_keys" \
	       "$HERE/config/includes.chroot/usr/bin/tailscale" \
	       "$HERE/config/includes.chroot/usr/bin/.tailscale-version" \
	       "$HERE/config/includes.chroot/usr/sbin/tailscaled" \
	       "$HERE/config/includes.chroot/etc/systemd/system/tailscaled.service" \
	       "$HERE/config/includes.chroot/etc/default/tailscaled" \
	       "$HERE/config/includes.chroot/opt/mlos-host-utils" \
	       "$HERE/config/packages.chroot"
	say "Cleaned (cache/ kept)"
}

case "${1:-build}" in
	build) do_build ;;
	clean) do_clean ;;
	shell) build_builder_image
	       docker run --rm -it --privileged --network host \
			-v "$HERE:/build" -w /build "$IMAGE" bash ;;
	*) die "usage: $0 [build|clean|shell]" ;;
esac
