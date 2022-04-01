{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.mate-wayland;

  startSessionScript = pkgs.writeScriptBin "mate-wayland" ''
    #!${pkgs.stdenv.shell}
    set -euo pipefail

    export WAYLAND_DISPLAY=wayland-mate # This will be the Wayland display Mirco creates
    export XDG_RUNTIME_DIR=/run/user/$(id -u) # Since this is a classic snap, this should be set to the normal value

    # Once Mir starts up, it will drop the X11 display number into this file
    XWAYLAND_DISPLAY_FILE=$(mktemp mir-x11-display.XXXXXX --tmpdir)

    # Enable XWayland and set up Mir to work
    export MIR_SERVER_ENABLE_X11=1
    export MIR_SERVER_XWAYLAND_PATH=${pkgs.xwayland}/bin/Xwayland

    ${pkgs.nur.repos.ilya-fedin.mirco}/bin/mirco $@ --x11-displayfd 5 5>"$XWAYLAND_DISPLAY_FILE" &
    SERVER_PID=$!

    echo "Waiting for DISPLAY to appear in $XWAYLAND_DISPLAY_FILE"
    while test -z $(cat "$XWAYLAND_DISPLAY_FILE"); do
      sleep 0.05
    done
    export DISPLAY=":$(cat "$XWAYLAND_DISPLAY_FILE")"
    rm "$XWAYLAND_DISPLAY_FILE"
    echo "DISPLAY=$DISPLAY, $XWAYLAND_DISPLAY_FILE deleted"

    # Wait for the socket to appear
    SOCKET_PATH="$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"
    i=0
    while test ! -S "$SOCKET_PATH"; do
        if ! kill -0 "$SERVER_PID" 2>/dev/null; then
            echo "ERROR: server failed to start"
            exit 1
        fi
        i=$((i + 1))
        if test $i -gt 50; then
            echo "ERROR: server did not create $WAYLAND_DISPLAY"
            kill -9 "$SERVER_PID"
            wait "$SERVER_PID"
            exit 1
        fi
        sleep 0.05
    done

    echo "WAYLAND_DISPLAY: ''${WAYLAND_DISPLAY:-[nil]}"
    echo "XDG_RUNTIME_DIR: ''${XDG_RUNTIME_DIR:-[nil]}"
    echo "DISPLAY: ''${DISPLAY:-[nil]}"
    systemctl --user import-environment

    COMPONENT_PIDS=""

    GDK_BACKEND=x11 ${pkgs.mate.mate-session-manager}/bin/mate-session &
    COMPONENT_PIDS="$COMPONENT_PIDS $!"

    ${pkgs.mate.mate-panel}/bin/mate-panel &
    COMPONENT_PIDS="$COMPONENT_PIDS $!"

    ${pkgs.nur.repos.ilya-fedin.gtk-layer-background}/bin/gtk-layer-background -i "$(eval "echo $(dconf read /org/mate/desktop/background/picture-filename)")" &
    COMPONENT_PIDS="$COMPONENT_PIDS $!"

    # Wait for all components and the server to exit
    wait $COMPONENT_PIDS $SERVER_PID
  '';

  sessionPkg = pkgs.runCommand "mate-wayland-session" {
    preferLocalBuild = true;
    passthru.providedSessions = [ "mate-wayland" ];
  } ''
    mkdir -p "$out/share/wayland-sessions"
    cat <<EOF > "$out/share/wayland-sessions/mate-wayland.desktop"
    [Desktop Entry]
    Name=MATE
    Exec=${startSessionScript}/bin/mate-wayland
    TryExec=${startSessionScript}/bin/mate-wayland
    Type=Application
    DesktopNames=MATE
    EOF
  '';
in {
  options = {
    programs.mate-wayland = {
      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Enable MATE Wayland session.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ (import ../../overlays/mate-wayland) ];
    services.xserver.desktopManager.mate.enable = true;
    services.xserver.displayManager.sessionPackages = [ sessionPkg ];
  };
}
