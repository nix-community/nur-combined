{
  lib,
  stdenv,
  qq,
  bubblewrap,
  makeWrapper,
}:

# Adapted from https://aur.archlinux.org/packages/linuxqq-nt-bwrap
# Original work by Kirikaze Chiyuki and sukanka

stdenv.mkDerivation (finalAttrs: {
  pname = "qq_bwrap";
  version = qq.version;

  nativeBuildInputs = [ makeWrapper ];

  src = qq;

  buildPhase = ''
    runHook preBuild
    # Nothing to build, just wrap
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    
    mkdir -p $out/bin $out/share
    
    # Copy desktop and icons from qq
    if [ -d "${qq}/share/applications" ]; then
      cp -r ${qq}/share/applications $out/share/
    fi
    if [ -d "${qq}/share/icons" ]; then
      cp -r ${qq}/share/icons $out/share/
    fi
    
    # We will replace the Exec line in the desktop file to point to our wrapper
    if [ -f "$out/share/applications/qq.desktop" ]; then
      substituteInPlace $out/share/applications/qq.desktop \
        --replace-fail "Exec=${qq}/bin/qq" "Exec=qq" \
        --replace-fail "Icon=${qq}/share/icons/hicolor/512x512/apps/qq.png" "Icon=qq"
    fi
    
    # Provide the wrapper script
    cat << 'EOF' > $out/bin/qq
    #!/bin/bash
    
    USER_RUN_DIR="/run/user/$(id -u)"
    XAUTHORITY="''${XAUTHORITY:-$HOME/.Xauthority}"
    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    FONTCONFIG_HOME="''${XDG_CONFIG_HOME}/fontconfig"
    QQ_APP_DIR="''${XDG_CONFIG_HOME}/QQ"
    if [ -z "''${QQ_DOWNLOAD_DIR}" ]; then
        if command -v xdg-user-dir >/dev/null 2>&1; then
            XDG_DOWNLOAD_DIR="$(xdg-user-dir DOWNLOAD)"
        fi
        QQ_DOWNLOAD_DIR="''${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
    fi
    
    if [ "''${QQ_DOWNLOAD_DIR%/}" = "''${HOME}" ]; then
        QQ_DOWNLOAD_DIR="''${HOME}/Downloads"
    fi
    
    mkdir -p "''${QQ_APP_DIR}"
    mkdir -p "''${QQ_DOWNLOAD_DIR}"
    
    bwrap_flags_file="''${XDG_CONFIG_HOME}/qq-bwrap-flags.conf"
    declare -a bwrap_flags
    if [[ -f "''${bwrap_flags_file}" ]]; then
        while read -r line; do
            if [[ ! "''${line}" =~ ^[[:space:]]*# ]] && [[ -n "''${line}" ]]; then
                bwrap_flags+=("''${line}")
            fi
        done < "''${bwrap_flags_file}"
    fi
    
    electron_flags_file="''${XDG_CONFIG_HOME}/qq-electron-flags.conf"
    declare -a electron_flags
    if [[ -f "''${electron_flags_file}" ]]; then
        while read -r line; do
            if [[ ! "''${line}" =~ ^[[:space:]]*# ]] && [[ -n "''${line}" ]]; then
                electron_flags+=("''${line}")
            fi
        done < "''${electron_flags_file}"
    fi
    
    exec ${bubblewrap}/bin/bwrap \
        --new-session --cap-drop ALL --unshare-user-try --unshare-pid --unshare-cgroup-try \
        --ro-bind /nix /nix \
        --ro-bind-try /etc/machine-id /etc/machine-id \
        --ro-bind-try /etc/passwd /etc/passwd \
        --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf \
        --ro-bind-try /etc/resolv.conf /etc/resolv.conf \
        --ro-bind-try /etc/localtime /etc/localtime \
        --ro-bind-try /etc/fonts /etc/fonts \
        --ro-bind-try /etc/profiles /etc/profiles \
        --ro-bind-try /run/systemd/userdb /run/systemd/userdb \
        --ro-bind-try /run/current-system/sw /run/current-system/sw \
        --ro-bind-try /run/opengl-driver /run/opengl-driver \
        --dev-bind /dev /dev \
        --ro-bind /sys /sys \
        --tmpfs /sys/devices/virtual \
        --proc /proc \
        --dev-bind-try /run/dbus /run/dbus \
        --bind-try "''${USER_RUN_DIR}" "''${USER_RUN_DIR}" \
        --dev-bind /tmp /tmp \
        --bind-try "''${HOME}/.pki" "''${HOME}/.pki" \
        --ro-bind-try "''${XAUTHORITY}" "''${XAUTHORITY}" \
        --bind "''${QQ_DOWNLOAD_DIR}" "''${QQ_DOWNLOAD_DIR}" \
        --bind "''${QQ_APP_DIR}" "''${QQ_APP_DIR}" \
        --ro-bind-try "''${FONTCONFIG_HOME}" "''${FONTCONFIG_HOME}" \
        --ro-bind-try "''${HOME}/.icons" "''${HOME}/.icons" \
        --ro-bind-try "''${HOME}/.local/share/.icons" "''${HOME}/.local/share/.icons" \
        --ro-bind-try "''${XDG_CONFIG_HOME}/gtk-3.0" "''${XDG_CONFIG_HOME}/gtk-3.0" \
        --ro-bind-try "''${XDG_CONFIG_HOME}/dconf" "''${XDG_CONFIG_HOME}/dconf" \
        --setenv IBUS_USE_PORTAL 1 \
        --setenv QQNTIM_HOME "''${QQ_APP_DIR}/QQNTim" \
        --setenv LITELOADERQQNT_PROFILE "''${QQ_APP_DIR}/LiteLoaderQQNT" \
        "''${bwrap_flags[@]}" \
        ${qq}/bin/qq "''${electron_flags[@]}" "$@"
    EOF
    
    chmod +x $out/bin/qq
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "New Linux QQ based on Electron, with bubblewrap sandbox and some tweaks";
    homepage = "https://im.qq.com/linuxqq/index.shtml";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    mainProgram = "qq";
  };
})
