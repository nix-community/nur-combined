# Adapted from https://aur.archlinux.org/packages/wechat-universal-bwrap
# Original Maintainers: 7Ji <pugokushin at gmail dot com>, leaeasy <leaeasy at gmail dot com>
# Contributor: devome <evinedeng at hotmail dot com>
{
  lib,
  stdenv,
  wechat,
  bubblewrap,
  flatpak-xdg-utils,
  xdg-user-dirs,
  # Overlay real XDG dirs into the fake sandbox $HOME for send-file.
  bindDownloads ? true,
  bindDesktop ? false,
  bindDocuments ? false,
  # LD_PRELOAD libwechat_appearance.so (from wechat_appearance_plugin). Opt-in.
  followSystemAppearance ? false,
  wechat_appearance_plugin,
}:

stdenv.mkDerivation {
  pname = "wechat-universal-bwrap";
  version = wechat.version;

  src = ./.;

  buildPhase = ''
    runHook preBuild
    $CC -shared -fPIC -o libuosdevicea.so libuosdevicea.c
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    local wechat_root="$out/libexec/wechat-universal"

    install -Dm755 libuosdevicea.so "$wechat_root/usr/lib/license/libuosdevicea.so"
    echo 'DISTRIB_ID=uos' | install -Dm644 /dev/stdin "$wechat_root/etc/lsb-release"

    # buildFHSEnv makes /usr/lib an absolute symlink to /usr/lib64. bwrap then fails with
    # "Can't mkdir /usr/lib/license: No such file or directory" when overlaying the UOS
    # license dir. Rebuild a thin /usr with a relative lib->lib64 link and a real
    # lib64/license mount point so the later --ro-bind succeeds on the read-only tree.
    mkdir -p "$wechat_root/fhs-usr/lib64/license"
    # fhs-usr/bin must be a real directory (not a symlink) so we can replace
    # individual entries (e.g. the lsblk stub below) without mutating the FHS
    # env.  Same reason lib64 is expanded rather than symlinked.
    mkdir -p "$wechat_root/fhs-usr/bin"
    for entry in "${wechat.fhsenv}"/usr/*; do
      name=$(basename "$entry")
      case "$name" in
        bin)
          for binentry in "$entry"/*; do
            ln -s "$binentry" "$wechat_root/fhs-usr/bin/$(basename "$binentry")"
          done
          ;;
        lib)
          ln -s lib64 "$wechat_root/fhs-usr/lib"
          ;;
        lib64)
          for libentry in "$entry"/*; do
            ln -s "$libentry" "$wechat_root/fhs-usr/lib64/$(basename "$libentry")"
          done
          ;;
        *)
          ln -s "$entry" "$wechat_root/fhs-usr/$name"
          ;;
      esac
    done
    # bwrap cannot bind-mount over a symlink destination in a read-only /usr
    # ("Can't create file at /usr/bin/lsblk").  Nixpkgs coreutils is also a
    # multicall binary, so binding coreutils' true over lsblk yields
    # "unknown program 'lsblk'".  Install a real always-success stub instead
    # (AUR's --bind /usr/bin/true /usr/bin/lsblk anti-VM workaround).
    rm -f "$wechat_root/fhs-usr/bin/lsblk"
    printf '%s\n' '#!/bin/sh' 'exit 0' | install -Dm755 /dev/stdin "$wechat_root/fhs-usr/bin/lsblk"

    install -Dm755 wechat-universal.sh "$wechat_root/common.sh"
    install -Dm644 pulse-client.conf "$wechat_root/pulse-client.conf"

    substituteInPlace "$wechat_root/common.sh" \
      --replace-fail "/{usr/lib/flatpak-xdg-utils,sandbox}/xdg-open" "${flatpak-xdg-utils}/bin/xdg-open /sandbox/xdg-open" \
      --replace-fail "/usr/lib/wechat-universal/common.sh" "$wechat_root/common.sh" \
      --replace-fail "/usr/lib/wechat-universal/pulse-client.conf" "$wechat_root/pulse-client.conf" \
      --replace-fail "/opt/wechat-universal{,}" "${wechat.src}/opt/wechat /opt/wechat-universal" \
      --replace-fail "{/usr/lib/wechat-universal,}/usr/lib/license" "$wechat_root/usr/lib/license /usr/lib/license" \
      --replace-fail "{/usr/lib/wechat-universal,}/etc/lsb-release" "$wechat_root/etc/lsb-release /etc/lsb-release" \
      --replace-fail "--ro-bind /usr{,}" "--ro-bind /nix /nix --ro-bind-try /run/current-system/sw /run/current-system/sw --ro-bind-try /run/opengl-driver /run/opengl-driver --ro-bind $wechat_root/fhs-usr /usr" \
      --replace-fail "--bind /usr/bin/{true,lsblk}" "" \
      --replace-fail 'exec bwrap "' 'exec ${bubblewrap}/bin/bwrap "' \
      --replace-fail "'start.sh'|'start'|'wechat-universal.sh'|'wechat-universal')" "'start.sh'|'start'|'wechat-universal.sh'|'wechat-universal'|'wechat')" \
      --replace-fail 'PATH="/sandbox:''${PATH}"' 'PATH="/sandbox:''${PATH}" LD_LIBRARY_PATH="/usr/lib:/usr/lib64"' \
      --replace-fail '--dev-bind /run/dbus{,}' '--dev-bind-try /run/dbus{,}' \
      --replace-fail '--ro-bind "''${DBUS_SESSION_BUS_PATH}"{,}' '--ro-bind-try "''${DBUS_SESSION_BUS_PATH}"{,}' \
      --replace-fail '@bindDownloads@' '${if bindDownloads then "1" else "0"}' \
      --replace-fail '@bindDesktop@' '${if bindDesktop then "1" else "0"}' \
      --replace-fail '@bindDocuments@' '${if bindDocuments then "1" else "0"}' \
      --replace-fail '@xdgUserDir@' '${xdg-user-dirs}/bin/xdg-user-dir' \
      --replace-fail '@appearancePreloadBlock@' ${
        lib.escapeShellArg (
          if followSystemAppearance then
            "\n    # LD_PRELOAD follow-system appearance (wechat_appearance_plugin).\n        BWRAP_ARGS+=(--setenv LD_PRELOAD \"${wechat_appearance_plugin}/lib/libwechat_appearance.so\${LD_PRELOAD:+:$LD_PRELOAD}\")\n"
          else
            ""
        )
      }

    mkdir -p $out/bin
    ln -s $wechat_root/common.sh $out/bin/wechat-universal
    ln -s $wechat_root/common.sh $out/bin/wechat
    ln -s $wechat_root/common.sh $out/bin/start.sh
    ln -s $wechat_root/common.sh $out/bin/start
    ln -s $wechat_root/common.sh $out/bin/stop.sh
    ln -s $wechat_root/common.sh $out/bin/stop

    install -Dm644 wechat-universal.desktop $out/share/applications/wechat-universal.desktop
    substituteInPlace $out/share/applications/wechat-universal.desktop \
      --replace-fail "/usr/lib/wechat-universal" "$out/bin"

    install -Dm644 wechat-license $out/share/licenses/wechat-universal/wechat-license

    install -Dm644 ${wechat.src}/wechat.png $out/share/icons/hicolor/256x256/apps/wechat-universal.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "WeChat (Universal) with bwrap sandbox (adapted from AUR)";
    homepage = "https://linux.weixin.qq.com/";
    license = licenses.unfree;
    maintainers = [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "wechat-universal";
  };
}
