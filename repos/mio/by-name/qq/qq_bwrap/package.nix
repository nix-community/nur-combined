{
  lib,
  stdenv,
  qq,
  bubblewrap,
  flatpak-xdg-utils,
  # GTK IM module for Electron-on-XWayland (Linux QQ's Wayland IME is unreliable).
  fcitx5-gtk,
  iproute2,
  withMacFix ? true,
  # Overlay real XDG dirs into the sandbox for send-file / downloads.
  bindDownloads ? true,
  bindDesktop ? false,
  bindDocuments ? false,
  slirp4netns,
  socat,
  xdg-user-dirs,
}:

# Adapted from https://aur.archlinux.org/packages/linuxqq-nt-bwrap
# Original work by Kirikaze Chiyuki and sukanka

stdenv.mkDerivation {
  pname = "qq_bwrap";
  version = qq.version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/libexec $out/share

    # Copy desktop and icons from qq
    if [ -d "${qq}/share/applications" ]; then
      cp -r ${qq}/share/applications $out/share/
    fi
    if [ -d "${qq}/share/icons" ]; then
      cp -r ${qq}/share/icons $out/share/
    fi

    if [ -f "$out/share/applications/qq.desktop" ]; then
      substituteInPlace $out/share/applications/qq.desktop \
        --replace-fail "Exec=${qq}/bin/qq" "Exec=$out/bin/qq" \
        --replace-fail "Icon=${qq}/share/icons/hicolor/512x512/apps/qq.png" "Icon=qq"
    fi

    # Portal-backed xdg-open; drop jsbridge URIs like the AUR workaround.
    cat << 'EOF' > $out/libexec/qq-xdg-open
    #!/bin/bash
    URI_TO_OPEN="$1"
    if [ "''${URI_TO_OPEN:0:8}" != "jsbridge" ]; then
        exec ${flatpak-xdg-utils}/bin/xdg-open "$URI_TO_OPEN"
    fi
    EOF

    # Source after electron_flags is declared.
    # Linux QQ's Electron Wayland IME is unreliable (even when other apps + host
    # fcitx5 are fine under NIXOS_OZONE_WL). Default fcitx → XWayland + GTK IM
    # (community fix). Override: QQ_IME_WORKAROUND=wayland|fcitx|ibus|x11|none.
    cat << 'EOF' > $out/libexec/qq-setup-ime.sh
    #!/bin/bash
    _qq_flags_have() {
        printf '%s\0' "''${electron_flags[@]}" | grep -qz -- "$1"
    }
    _qq_detect_im() {
        case "''${XMODIFIERS}" in
            *@im=fcitx*) printf fcitx; return ;;
            *@im=ibus*) printf ibus; return ;;
        esac
        case "''${GTK_IM_MODULE}:''${QT_IM_MODULE}" in
            *fcitx*) printf fcitx; return ;;
            *ibus*) printf ibus; return ;;
        esac
        printf none
    }
    if [ -z "''${QQ_IME_WORKAROUND}" ] || [ "''${QQ_IME_WORKAROUND}" = auto ]; then
        case "$(_qq_detect_im)" in
            fcitx)
                # Prefer XWayland over native Wayland text-input for this app.
                QQ_IME_WORKAROUND=x11
                ;;
            ibus)
                if [ -n "''${WAYLAND_DISPLAY}" ]; then
                    QQ_IME_WORKAROUND=wayland
                else
                    QQ_IME_WORKAROUND=ibus
                fi
                ;;
            *)
                if [ -n "''${WAYLAND_DISPLAY}" ]; then
                    QQ_IME_WORKAROUND=wayland
                else
                    QQ_IME_WORKAROUND=none
                fi
                ;;
        esac
    fi
    case "''${QQ_IME_WORKAROUND}" in
        wayland)
            unset GTK_IM_MODULE QT_IM_MODULE QT_IM_MODULES SDL_IM_MODULE IBUS_USE_PORTAL \
                2>/dev/null || true
            if ! _qq_flags_have 'ozone-platform'; then
                electron_flags+=(--ozone-platform-hint=auto)
            fi
            if ! _qq_flags_have 'enable-wayland-ime'; then
                electron_flags+=(--enable-wayland-ime=true)
            fi
            case "''${XDG_CURRENT_DESKTOP:-}:''${XDG_SESSION_DESKTOP:-}" in
                *KDE*|*Plasma*)
                    # Overrides nixpkgs qq's text-input-v3 under NIXOS_OZONE_WL.
                    electron_flags+=(--wayland-text-input-version=1)
                    ;;
                *)
                    if ! _qq_flags_have 'wayland-text-input-version'; then
                        electron_flags+=(--wayland-text-input-version=3)
                    fi
                    ;;
            esac
            ;;
        fcitx)
            export QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx
            export XMODIFIERS="''${XMODIFIERS:-@im=fcitx}"
            export GTK_PATH="@fcitx5Gtk@/lib/gtk-3.0''${GTK_PATH:+:$GTK_PATH}"
            unset IBUS_USE_PORTAL 2>/dev/null || true
            ;;
        ibus)
            export QT_IM_MODULE=ibus GTK_IM_MODULE=ibus IBUS_USE_PORTAL=1
            ;;
        x11)
            # Drop NIXOS_OZONE_WL so nixpkgs qq wrapper does not inject Wayland
            # ozone/IME flags ahead of --ozone-platform=x11.
            unset NIXOS_OZONE_WL IBUS_USE_PORTAL 2>/dev/null || true
            export QT_IM_MODULE=fcitx GTK_IM_MODULE=fcitx
            export SDL_IM_MODULE=fcitx
            export XMODIFIERS="''${XMODIFIERS:-@im=fcitx}"
            export ELECTRON_OZONE_PLATFORM_HINT=x11
            export GTK_PATH="@fcitx5Gtk@/lib/gtk-3.0''${GTK_PATH:+:$GTK_PATH}"
            electron_flags+=(--ozone-platform=x11)
            ;;
    esac
    unset -f _qq_flags_have _qq_detect_im
    EOF

    # Source after HOME is known. Fills QQ_USER_DIR_BINDS for bwrap
    # (same Nix flags as wechat_bwrap: bindDownloads / bindDesktop / bindDocuments).
    cat << 'EOF' > $out/libexec/qq-setup-user-dirs.sh
    #!/bin/bash
    declare -a QQ_USER_DIR_BINDS=()
    _qq_add_user_dir() {
        local dir="$1"
        if [ -n "''${dir}" ] && [ "''${dir}" != "''${HOME}" ] && [ "''${dir}" != / ]; then
            mkdir -p "''${dir}"
            QQ_USER_DIR_BINDS+=(--bind-try "''${dir}" "''${dir}")
        fi
    }
    _qq_xdg_dir() {
        # $1: env var name, $2: xdg-user-dir key, $3: fallback under $HOME
        local dir="''${!1:-}"
        if [ -z "''${dir}" ]; then
            dir="$(@xdgUserDir@ "$2" 2>/dev/null || true)"
        fi
        printf '%s\n' "''${dir:-$HOME/$3}"
    }
    if [ @bindDownloads@ -eq 1 ]; then
        if [ -z "''${QQ_DOWNLOAD_DIR}" ]; then
            QQ_DOWNLOAD_DIR="$(_qq_xdg_dir XDG_DOWNLOAD_DIR DOWNLOAD Downloads)"
        fi
        if [ "''${QQ_DOWNLOAD_DIR%/}" = "''${HOME}" ]; then
            QQ_DOWNLOAD_DIR="''${HOME}/Downloads"
        fi
        _qq_add_user_dir "''${QQ_DOWNLOAD_DIR}"
    fi
    if [ @bindDesktop@ -eq 1 ]; then
        _qq_add_user_dir "$(_qq_xdg_dir XDG_DESKTOP_DIR DESKTOP Desktop)"
    fi
    if [ @bindDocuments@ -eq 1 ]; then
        _qq_add_user_dir "$(_qq_xdg_dir XDG_DOCUMENTS_DIR DOCUMENTS Documents)"
    fi
    unset -f _qq_add_user_dir _qq_xdg_dir
    EOF

    cat << 'EOF' > $out/libexec/qq_normal
    #!/bin/bash

    USER_RUN_DIR="/run/user/$(id -u)"
    XAUTHORITY="''${XAUTHORITY:-$HOME/.Xauthority}"
    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    FONTCONFIG_HOME="''${XDG_CONFIG_HOME}/fontconfig"
    QQ_APP_DIR="''${XDG_CONFIG_HOME}/QQ"

    mkdir -p "''${QQ_APP_DIR}"
    # shellcheck source=/dev/null
    source @out@/libexec/qq-setup-user-dirs.sh

    bwrap_flags_file="''${XDG_CONFIG_HOME}/qq-bwrap-flags.conf"
    declare -a bwrap_flags
    if [[ -f "''${bwrap_flags_file}" ]]; then
        while IFS= read -r line; do
            if [[ ! "''${line}" =~ ^[[:space:]]*# ]] && [[ -n "''${line}" ]]; then
                eval "expanded_line=\"$line\""
                read -ra parts <<< "$expanded_line"
                for part in "''${parts[@]}"; do
                    bwrap_flags+=("$part")
                done
            fi
        done < "''${bwrap_flags_file}"
    fi

    electron_flags_file="''${XDG_CONFIG_HOME}/qq-electron-flags.conf"
    declare -a electron_flags
    if [[ -f "''${electron_flags_file}" ]]; then
        mapfile -t ELECTRON_FLAGS_MAPFILE <"''${electron_flags_file}"
    fi
    for line in "''${ELECTRON_FLAGS_MAPFILE[@]}"; do
        if [[ ! "''${line}" =~ ^[[:space:]]*#.* ]]; then
            electron_flags+=("''${line}")
        fi
    done
    # shellcheck source=/dev/null
    source @out@/libexec/qq-setup-ime.sh

    # 移除无用崩溃报告和日志 (Before start)
    rm -rf "''${QQ_APP_DIR}/crash_files"
    touch "''${QQ_APP_DIR}/crash_files"
    if [ -d "''${QQ_APP_DIR}/log" ]; then
        rm -rf "''${QQ_APP_DIR}/log"
    fi
    for nt_qq_userdata in "''${QQ_APP_DIR}/nt_qq_"*; do
        if [ -d "''${nt_qq_userdata}/log" ]; then
            rm -rf "''${nt_qq_userdata}/log"
        fi
        if [ -d "''${nt_qq_userdata}/log-cache" ]; then
            rm -rf "''${nt_qq_userdata}/log-cache"
        fi
    done
    if [ -d "''${QQ_APP_DIR}/Crashpad" ]; then
        rm -rf "''${QQ_APP_DIR}/Crashpad"
    fi

    # 处理旧版本/热更新
    QQ_HOTUPDATE_DIR="''${QQ_APP_DIR}/versions"
    if [ -d "''${QQ_HOTUPDATE_DIR}" ]; then
        rm -rf "''${QQ_HOTUPDATE_DIR}/"*.zip
    fi

    export PATH="${flatpak-xdg-utils}/bin:$PATH"

    ${bubblewrap}/bin/bwrap \
        --new-session --cap-drop ALL --unshare-user-try --unshare-pid --unshare-cgroup-try \
        --ro-bind /nix /nix \
        --ro-bind-try /bin /bin \
        --tmpfs /usr/bin \
        --ro-bind-try /usr/bin/env /usr/bin/env \
        --ro-bind @out@/libexec/qq-xdg-open /usr/bin/xdg-open \
        --ro-bind-try /etc/machine-id /etc/machine-id \
        --ro-bind-try /etc/passwd /etc/passwd \
        --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf \
        --ro-bind-try /etc/resolv.conf /etc/resolv.conf \
        --ro-bind-try /etc/localtime /etc/localtime \
        --ro-bind-try /etc/fonts /etc/fonts \
        --ro-bind-try /etc/ssl /etc/ssl \
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
        "''${QQ_USER_DIR_BINDS[@]}" \
        --bind "''${QQ_APP_DIR}" "''${QQ_APP_DIR}" \
        --ro-bind-try "''${FONTCONFIG_HOME}" "''${FONTCONFIG_HOME}" \
        --ro-bind-try "''${HOME}/.icons" "''${HOME}/.icons" \
        --ro-bind-try "''${HOME}/.local/share/icons" "''${HOME}/.local/share/icons" \
        --ro-bind-try "''${XDG_CONFIG_HOME}/gtk-3.0" "''${XDG_CONFIG_HOME}/gtk-3.0" \
        --ro-bind-try "''${XDG_CONFIG_HOME}/dconf" "''${XDG_CONFIG_HOME}/dconf" \
        --setenv QQNTIM_HOME "''${QQ_APP_DIR}/QQNTim" \
        --setenv LITELOADERQQNT_PROFILE "''${QQ_APP_DIR}/LiteLoaderQQNT" \
        "''${bwrap_flags[@]}" \
        ${qq}/bin/qq "''${electron_flags[@]}" "$@"

    EXIT_CODE=$?

    # 移除无用崩溃报告和日志 (After start)
    rm -rf "''${QQ_APP_DIR}/crash_files"
    touch "''${QQ_APP_DIR}/crash_files"
    if [ -d "''${QQ_APP_DIR}/log" ]; then
        rm -rf "''${QQ_APP_DIR}/log"
    fi
    for nt_qq_userdata in "''${QQ_APP_DIR}/nt_qq_"*; do
        if [ -d "''${nt_qq_userdata}/log" ]; then
            rm -rf "''${nt_qq_userdata}/log"
        fi
        if [ -d "''${nt_qq_userdata}/log-cache" ]; then
            rm -rf "''${nt_qq_userdata}/log-cache"
        fi
    done
    if [ -d "''${QQ_APP_DIR}/Crashpad" ]; then
        rm -rf "''${QQ_APP_DIR}/Crashpad"
    fi

    exit $EXIT_CODE
    EOF

    ${lib.optionalString withMacFix ''
      cat << 'EOF' > $out/libexec/qq_inner
      #!/bin/bash
      trap 'kill $(jobs -p)' EXIT
      echo $$ > "''${INFO_FILE}"
      while [ -f "''${INFO_FILE}" ]; do
          sleep 0.01
      done
      unset http_proxy https_proxy ftp_proxy all_proxy
      ${socat}/bin/socat tcp-listen:94301,reuseaddr,fork tcp:127.0.0.1:4301 &
      ${socat}/bin/socat tcp-listen:94310,reuseaddr,fork tcp:127.0.0.1:4310 &
      ${qq}/bin/qq --no-proxy-server "$@"
      EXIT_CODE=$?

      # 移除无用崩溃报告和日志
      rm -rf "''${QQ_APP_DIR}/crash_files"
      touch "''${QQ_APP_DIR}/crash_files"
      if [ -d "''${QQ_APP_DIR}/log" ]; then rm -rf "''${QQ_APP_DIR}/log"; fi
      for nt_qq_userdata in "''${QQ_APP_DIR}/nt_qq_"*; do
          if [ -d "''${nt_qq_userdata}/log" ]; then rm -rf "''${nt_qq_userdata}/log"; fi
          if [ -d "''${nt_qq_userdata}/log-cache" ]; then rm -rf "''${nt_qq_userdata}/log-cache"; fi
      done
      if [ -d "''${QQ_APP_DIR}/Crashpad" ]; then rm -rf "''${QQ_APP_DIR}/Crashpad"; fi
      exit $EXIT_CODE
      EOF

      cat << 'EOF' > $out/libexec/qq_mac_fix
      #!/bin/bash
      USER_RUN_DIR="/run/user/$(id -u)"
      XAUTHORITY="''${XAUTHORITY:-$HOME/.Xauthority}"
      XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      FONTCONFIG_HOME="''${XDG_CONFIG_HOME}/fontconfig"
      QQ_APP_DIR="''${XDG_CONFIG_HOME}/QQ"

      mkdir -p "''${QQ_APP_DIR}"
      # shellcheck source=/dev/null
      source @out@/libexec/qq-setup-user-dirs.sh

      bwrap_flags_file="''${XDG_CONFIG_HOME}/qq-bwrap-flags.conf"
      declare -a bwrap_flags
      if [[ -f "''${bwrap_flags_file}" ]]; then
          while IFS= read -r line; do
              if [[ ! "''${line}" =~ ^[[:space:]]*# ]] && [[ -n "''${line}" ]]; then
                  eval "expanded_line=\"$line\""
                  read -ra parts <<< "$expanded_line"
                  for part in "''${parts[@]}"; do
                      bwrap_flags+=("$part")
                  done
              fi
          done < "''${bwrap_flags_file}"
      fi
      electron_flags_file="''${XDG_CONFIG_HOME}/qq-electron-flags.conf"
      declare -a electron_flags
      if [[ -f "''${electron_flags_file}" ]]; then
          mapfile -t ELECTRON_FLAGS_MAPFILE <"''${electron_flags_file}"
      fi
      for line in "''${ELECTRON_FLAGS_MAPFILE[@]}"; do
          if [[ ! "''${line}" =~ ^[[:space:]]*#.* ]]; then
              electron_flags+=("''${line}")
          fi
      done
      # shellcheck source=/dev/null
      source @out@/libexec/qq-setup-ime.sh

      if [ -f "''${QQ_APP_DIR}/.qq_mac" ]; then
          qq_mac=$(cat "''${QQ_APP_DIR}/.qq_mac")
      else
          qq_mac=00\:$(hexdump -n5 -e '/1 ":%02X"' /dev/random | sed s/^://g)
          echo $qq_mac > "''${QQ_APP_DIR}/.qq_mac"
      fi

      # 清理和热更新预防
      rm -rf "''${QQ_APP_DIR}/crash_files"
      touch "''${QQ_APP_DIR}/crash_files"
      QQ_HOTUPDATE_DIR="''${QQ_APP_DIR}/versions"
      if [ -d "''${QQ_HOTUPDATE_DIR}" ]; then rm -rf "''${QQ_HOTUPDATE_DIR}/"*.zip; fi

      INFO_DIR=$(mktemp -d)
      INFO_FILE=$INFO_DIR/info
      echo "nameserver 10.0.2.3" > "$INFO_DIR/resolv.conf"

      export PATH="${flatpak-xdg-utils}/bin:$PATH"

      ${bubblewrap}/bin/bwrap --new-session --unshare-user-try --unshare-cgroup-try \
          --unshare-user \
          --uid "$(id -u)" --gid "$(id -g)" \
          --unshare-net \
          --cap-add CAP_NET_ADMIN,CAP_NET_RAW,CAP_SYS_ADMIN \
          --ro-bind /nix /nix \
          --ro-bind-try /bin /bin \
          --tmpfs /usr/bin \
          --ro-bind-try /usr/bin/env /usr/bin/env \
          --ro-bind @out@/libexec/qq-xdg-open /usr/bin/xdg-open \
          --ro-bind-try /etc/machine-id /etc/machine-id \
          --ro-bind-try /etc/passwd /etc/passwd \
          --ro-bind-try /etc/nsswitch.conf /etc/nsswitch.conf \
          --ro-bind "''${INFO_DIR}/resolv.conf" /etc/resolv.conf \
          --ro-bind-try /etc/localtime /etc/localtime \
          --ro-bind-try /etc/fonts /etc/fonts \
          --ro-bind-try /etc/ssl /etc/ssl \
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
          "''${QQ_USER_DIR_BINDS[@]}" \
          --setenv QQ_APP_DIR "''${QQ_APP_DIR}" \
          --bind "''${QQ_APP_DIR}" "''${QQ_APP_DIR}" \
          --ro-bind-try "''${FONTCONFIG_HOME}" "''${FONTCONFIG_HOME}" \
          --ro-bind-try "''${HOME}/.icons" "''${HOME}/.icons" \
          --ro-bind-try "''${HOME}/.local/share/icons" "''${HOME}/.local/share/icons" \
          --ro-bind-try "''${XDG_CONFIG_HOME}/gtk-3.0" "''${XDG_CONFIG_HOME}/gtk-3.0" \
          --ro-bind-try "''${XDG_CONFIG_HOME}/dconf" "''${XDG_CONFIG_HOME}/dconf" \
          --setenv QQNTIM_HOME "''${QQ_APP_DIR}/QQNTim" \
          --setenv LITELOADERQQNT_PROFILE "''${QQ_APP_DIR}/LiteLoaderQQNT" \
          --bind "''${INFO_DIR}" "''${INFO_DIR}" \
          --setenv INFO_FILE "''${INFO_FILE}" \
          "''${bwrap_flags[@]}" \
          @out@/libexec/qq_inner "''${electron_flags[@]}" "$@" &

      if [ "$?" -ne 0 ]; then
          rm "$INFO_FILE"
          exit 1
      fi
      while [ ! -s "$INFO_FILE" ]; do sleep 0.01; done
      PID="$(cat "$INFO_FILE")"

      SLIRP_API_SOCKET=$INFO_DIR/slirp.sock
      ${slirp4netns}/bin/slirp4netns --configure --mtu=65520 --disable-host-loopback --enable-ipv6 "$PID" eth0 --macaddress "$qq_mac" --api-socket "$SLIRP_API_SOCKET" &
      SLIRP_PID=$!
      while [ ! -S "$SLIRP_API_SOCKET" ]; do sleep 0.01; done

      if [ "$?" -ne 0 ]; then
          kill "$PID"
          rm -rf "''${INFO_DIR:?}"
          exit 1
      fi

      add_hostfwd() {
          local proto=$1
          local guest_port=$2
          shift 2
          local ports=("$@")
          for port in "''${ports[@]}"; do
              result=$(echo -n "{\"execute\": \"add_hostfwd\", \"arguments\": {\"proto\": \"$proto\", \"host_addr\": \"127.0.0.1\", \"host_port\": $port, \"guest_port\": $guest_port}}" | ${socat}/bin/socat UNIX-CONNECT:$SLIRP_API_SOCKET -)
              if [[ $result != *"error"* ]]; then
                  return 0
              fi
          done
          return 1
      }

      https_ports=(4301 4303 4305 4307 4309)
      http_ports=(4310 4308 4306 4304 4302)
      add_hostfwd "tcp" 94301 "''${https_ports[@]}"
      add_hostfwd "tcp" 94310 "''${http_ports[@]}"
      rm "$INFO_FILE"

      tail --pid="$PID" -f /dev/null
      set +e
      kill -TERM "$SLIRP_PID"
      wait "$SLIRP_PID"
      rm -rf "''${INFO_DIR:?}"
      exit 0
      EOF
    ''}

    cat << 'EOF' > $out/bin/qq
    #!/bin/bash
    XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"

    if [ "''${QQ_FIX_MAC}" != 1 ]; then
        if [ -s "''${XDG_CONFIG_HOME}/qq-fix-mac.conf" ]; then
            export QQ_FIX_MAC=1
        elif ${iproute2}/bin/ip link show 2>/dev/null | grep -q "docker"; then
            export QQ_FIX_MAC=1
        elif [ -n "$(${iproute2}/bin/ip tuntap 2>/dev/null)" ]; then
            export QQ_FIX_MAC=1
        fi
    fi

    if [ "''${QQ_FIX_MAC}" == 1 ]; then
        ${
          if withMacFix then
            ''exec @out@/libexec/qq_mac_fix "$@"''
          else
            ''
              echo "WARNING: QQ_FIX_MAC is set, but qq_bwrap was not built with withMacFix=true."
              echo "Please rebuild with withMacFix=true to use MAC spoofing. Falling back to normal."
              exec @out@/libexec/qq_normal "$@"
            ''
        }
    else
        exec @out@/libexec/qq_normal "$@"
    fi
    EOF

    # Quoted heredocs leave $out / bind flags literal; bake real values in.
    substituteInPlace $out/bin/qq $out/libexec/qq_normal ${lib.optionalString withMacFix "$out/libexec/qq_mac_fix"} \
      --replace-fail '@out@' "$out"
    substituteInPlace $out/libexec/qq-setup-ime.sh \
      --replace-fail '@fcitx5Gtk@' '${fcitx5-gtk}'
    substituteInPlace $out/libexec/qq-setup-user-dirs.sh \
      --replace-fail '@bindDownloads@' '${if bindDownloads then "1" else "0"}' \
      --replace-fail '@bindDesktop@' '${if bindDesktop then "1" else "0"}' \
      --replace-fail '@bindDocuments@' '${if bindDocuments then "1" else "0"}' \
      --replace-fail '@xdgUserDir@' '${xdg-user-dirs}/bin/xdg-user-dir'

    chmod +x $out/libexec/* $out/bin/*
    runHook postInstall
  '';

  meta = with lib; {
    description = "New Linux QQ based on Electron, with bubblewrap sandbox and some tweaks";
    homepage = "https://im.qq.com/linuxqq/index.shtml";
    license = licenses.unfree;
    maintainers = with maintainers; [ ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "qq";
  };
}
