{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, coreutils
, patchelf
, fuse3
, zstd
, zlib
, alsa-lib
, at-spi2-atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libGL
, libdrm
, libglvnd
, libnotify
, libsecret
, libva
, libvdpau
, libxkbcommon
, libjack2
, mesa
, nspr
, nss
, pango
, pipewire
, systemd
, e2fsprogs
, wayland
, vulkan-loader
, xkeyboard-config
, zenity
, xdg-utils
, libx11
, libxcomposite
, libxcursor
, libxdamage
, libxext
, libxfixes
, libxi
, libxrandr
, libxrender
, libxcb
, libxshmfence
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lazycat-cloud-client";
  version = "2.0.30";

  src = fetchurl {
    url = "https://dl.lazycat.cloud/client/desktop/stable/lzc-client-desktop_v${finalAttrs.version}.tar.zst";
    hash = "sha256-ShoUvXPEH9WSUO+dd9pd/K13NQGcaov+6FG6QJCJDQA=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
    zstd
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libc.musl-x86_64.so.1"
    # Optional legacy Wayland shell plugin; upstream does not ship the
    # matching Qt 6.8 private integration library.
    "libQt6WlShellIntegration.so.6"
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libdrm
    libnotify
    libsecret
    libva
    libvdpau
    libxkbcommon
    libjack2
    mesa
    nspr
    nss
    pango
    pipewire
    systemd
    e2fsprogs
    vulkan-loader
    libx11
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxcb
    libxshmfence
  ];

  unpackPhase = ''
    runHook preUnpack
    zstd -cd $src | tar xf -
    runHook postUnpack
  '';

  postPatch = ''
    substituteInPlace cloud.lazycat.client.policy \
      --replace-fail "__SETCAP_SCRIPT_PATH__" "$out/lib/lzc-client-desktop/core/linux_setcap.sh"
    substituteInPlace cloud.lazycat.client.policy \
      --replace-fail "auth_admin" "yes"
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/lzc-client-desktop
    mkdir -p $out/bin
    mkdir -p $out/share/polkit-1/actions
    mkdir -p $out/share/icons/hicolor/256x256/apps

    cp -r ./* $out/lib/lzc-client-desktop/

    mv $out/lib/lzc-client-desktop/core/lzc-core $out/lib/lzc-client-desktop/core/.lzc-core-wrapped

    cat > $out/lib/lzc-client-desktop/core/lzc-core << 'WRAPPEREOF'
#!/bin/sh
if [ -x /run/wrappers/bin/lzc-core ]; then
  exec /run/wrappers/bin/lzc-core "$@"
fi
exec "$(dirname "$0")/.lzc-core-wrapped" "$@"
WRAPPEREOF
    chmod +x $out/lib/lzc-client-desktop/core/lzc-core

    cp icon.png $out/share/icons/hicolor/256x256/apps/lzc-client.png

    cp cloud.lazycat.client.policy $out/share/polkit-1/actions/

    cat > $out/lib/lzc-client-desktop/core/linux_setcap.sh << 'SETCAPEOF'
#!/bin/sh
exit 0
SETCAPEOF
    chmod +x $out/lib/lzc-client-desktop/core/linux_setcap.sh

    mkdir -p $out/lib/lzc-client-desktop/fake/bin
    cat > $out/lib/lzc-client-desktop/fake/bin/getcap << 'GETCAPEOF'
#!/bin/sh
for p in "$@"; do
  case "$p" in
    *lzc-core*)
      printf '%s cap_net_admin=ep\n' "$p"
      ;;
  esac
done
GETCAPEOF
    chmod +x $out/lib/lzc-client-desktop/fake/bin/getcap

    cat > $out/bin/lzc-prepare-catlink << 'PREPARECATLINKEOF'
#!/bin/sh
set -u

quiet=0
for arg in "$@"; do
  case "$arg" in
    --quiet) quiet=1 ;;
  esac
done

log() {
  if [ "$quiet" -eq 0 ]; then
    printf '%s\n' "$*" >&2
  fi
}

prepare_one() {
  bin="$1"
  [ -f "$bin" ] || return 0

  root="$(dirname "$bin")"
  stamp="$root/.nix-patched-catlink"

  # Older releases of this package modified Catlink's ELF program headers.
  # Those files cannot be restored reliably, so remove the whole version from
  # the active tree and let the client download a pristine copy.  Fresh
  # Catlink files are never modified; nix-ld handles their /lib64 interpreter.
  if [ -f "$stamp" ]; then
    stale_root="$HOME/.local/share/catlink-stale"
    stale_dir="$stale_root/$(basename "$root").$$"
    @coreutils@/bin/mkdir -p "$stale_root"
    if @coreutils@/bin/mv "$root" "$stale_dir"; then
      log "quarantined previously patched catlink: $root"
    fi
    return 0
  fi
}

scan_once() {
  status=0
  for bin in "$HOME"/.local/share/catlink/*/catlink "$HOME"/.local/share/catlink/*/catlink-core; do
    [ -e "$bin" ] || continue
    prepare_one "$bin" || status=1
  done
  return "$status"
}

scan_once
PREPARECATLINKEOF
    substituteInPlace $out/bin/lzc-prepare-catlink \
      --replace-fail "@coreutils@" "${coreutils}"
    chmod +x $out/bin/lzc-prepare-catlink
    ln -s lzc-prepare-catlink $out/bin/lzc-patch-catlink

    makeWrapper $out/lib/lzc-client-desktop/lzc-client-desktop $out/bin/lzc-client-desktop \
      --chdir "$out/lib/lzc-client-desktop" \
      --prefix PATH : ${lib.makeBinPath [ coreutils fuse3 libnotify xdg-utils zstd zenity ]} \
      --prefix PATH : /run/wrappers/bin \
      --prefix PATH : $out/lib/lzc-client-desktop/fake/bin \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        dbus
        libGL
        libdrm
        libglvnd
        libnotify
        libva
        libxext
        libxfixes
        libxkbcommon
        libxrandr
        mesa
        vulkan-loader
      ]} \
      --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
      --set-default LIBVA_DRIVERS_PATH /run/opengl-driver/lib/dri:${mesa}/lib/dri \
      --set-default __EGL_VENDOR_LIBRARY_DIRS /run/opengl-driver/share/glvnd/egl_vendor.d:${libglvnd}/share/glvnd/egl_vendor.d \
      --set-default ELECTRON_OZONE_PLATFORM_HINT auto \
      --set-default XKB_CONFIG_ROOT ${xkeyboard-config}/share/X11/xkb \
      --set-default DBUS_SYSTEM_BUS_ADDRESS unix:path=/run/dbus/system_bus_socket \
      --set-default FONTCONFIG_FILE ${fontconfig.out}/etc/fonts/fonts.conf \
      --run 'if [ -z "''${DBUS_SESSION_BUS_ADDRESS:-}" ] && [ -n "''${XDG_RUNTIME_DIR:-}" ]; then export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"; fi' \
      --set-default NIX_LD ${stdenv.cc.bintools.dynamicLinker} \
      --run 'export NIX_LD_LIBRARY_PATH="${lib.makeLibraryPath [
        stdenv.cc.libc
        zlib
        wayland
        libxcb
        libxkbcommon
        libglvnd
      ]}:''${NIX_LD_LIBRARY_PATH:-}"' \
      --run "$out/bin/lzc-prepare-catlink --quiet || true"

    runHook postInstall
  '';

  preFixup = ''
    # autoPatchelf sees the player's bundled libraries and may add that
    # directory to unrelated executables.  In particular, its older GLib
    # must not be mixed with nixpkgs' GObject/GIO used by Electron.
    removePlayerRpath() {
      local playerLib="$out/lib/lzc-client-desktop/player/lzc-player/usr/lib"
      find "$out/lib/lzc-client-desktop" -type f -perm -0100 -print0 \
        | while IFS= read -r -d $'\0' elf; do
          case "$elf" in
            "$out/lib/lzc-client-desktop/player/lzc-player/"*) continue ;;
          esac

          rpath="$(${patchelf}/bin/patchelf --print-rpath "$elf" 2>/dev/null || true)"
          case ":$rpath:" in
            *":$playerLib:"*)
              cleanRpath=""
              oldIFS="$IFS"
              IFS=:
              for path in $rpath; do
                [ "$path" = "$playerLib" ] && continue
                if [ -n "$cleanRpath" ]; then
                  cleanRpath="$cleanRpath:$path"
                else
                  cleanRpath="$path"
                fi
              done
              IFS="$oldIFS"
              ${patchelf}/bin/patchelf --set-rpath "$cleanRpath" "$elf"
              ;;
          esac
        done
    }

    # Electron 43's crashpad handler links GLib directly.  autoPatchelf
    # may satisfy that NEEDED entry with the player's bundled GLib, which
    # removePlayerRpath then strips from non-player executables, leaving
    # chrome_crashpad_handler with no libglib provider and aborting the
    # app right after startup.  Point such executables at nixpkgs' GLib.
    ensureGlibRpath() {
      local glibLib="${lib.getLib glib}/lib"
      find "$out/lib/lzc-client-desktop" -type f -perm -0100 -print0 \
        | while IFS= read -r -d $'\0' elf; do
          case "$elf" in
            "$out/lib/lzc-client-desktop/player/lzc-player/"*) continue ;;
          esac

          needed="$(${patchelf}/bin/patchelf --print-needed "$elf" 2>/dev/null || true)"
          case "$needed" in
            *libglib-2.0.so.0*)
              rpath="$(${patchelf}/bin/patchelf --print-rpath "$elf" 2>/dev/null || true)"
              case ":$rpath:" in
                *":$glibLib:"*) ;;
                *)
                  if [ -n "$rpath" ]; then
                    ${patchelf}/bin/patchelf --set-rpath "$rpath:$glibLib" "$elf"
                  else
                    ${patchelf}/bin/patchelf --set-rpath "$glibLib" "$elf"
                  fi
                  ;;
              esac
              ;;
          esac
        done
    }

    updateNetDiagnosticManifest() {
      local nativeDir="$out/lib/lzc-client-desktop/plugin/net-diagnostic/native/linux-x64"
      local manifest="$nativeDir/build-info.json"
      local node="$nativeDir/lzc-net-diagnostic.node"

      if [ ! -f "$manifest" ] || [ ! -f "$node" ]; then
        return 0
      fi

      local actual recorded
      actual="$(sha256sum "$node" | cut -d ' ' -f 1)"
      recorded="$(sed -n '/"name": "lzc-net-diagnostic.node"/,/}/{s/.*"sha256": "\([^"]*\)".*/\1/p}' "$manifest" | head -n1)"

      if [ -n "$recorded" ] && [ "$actual" != "$recorded" ]; then
        sed -i "/\"name\": \"lzc-net-diagnostic.node\"/,/}/s/\"sha256\": \"$recorded\"/\"sha256\": \"$actual\"/" "$manifest"
      fi
    }

    postFixupHooks+=(removePlayerRpath)
    postFixupHooks+=(ensureGlibRpath)
    postFixupHooks+=(updateNetDiagnosticManifest)
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "lzc-client";
      exec = "lzc-client-desktop";
      icon = "lzc-client";
      comment = "LazyCat micro-server client";
      desktopName = "懒猫微服";
      categories = [ "Network" ];
      mimeTypes = [ "x-scheme-handler/lzc" ];
      startupWMClass = "lzc-client-desktop";
      keywords = [ "lazycat" "lzc" ];
    })
  ];

  meta = with lib; {
    description = "LazyCat Cloud desktop client — a micro-server platform for personal cloud services";
    homepage = "https://lazycat.cloud";
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    mainProgram = "lzc-client-desktop";
    platforms = platforms.linux;
    badPlatforms = [ "aarch64-linux" ];
    maintainers = with maintainers; [ ];
  };
})
