{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.mate-wayland;

  startSessionScript = pkgs.writeShellScriptBin "mate-wayland" ''
    set -euo pipefail

    export WAYLAND_DISPLAY=wayland-mate # This will be the Wayland display Mirco creates
    export XDG_SESSION_TYPE=wayland # Tell to applications we're on Wayland

    # Once Mir starts up, it will drop the X11 display number into this file
    XWAYLAND_DISPLAY_FILE=$(mktemp mir-x11-display.XXXXXX --tmpdir)

    # Enable XWayland and set up Mir to work
    export MIR_SERVER_ENABLE_X11=1
    export MIR_SERVER_XWAYLAND_PATH=${pkgs.xwayland}/bin/Xwayland

    # Set cursor theme and size
    export XDG_DATA_DIRS="${pkgs.glib.getSchemaDataDirPath pkgs.mate.mate-settings-daemon}:$XDG_DATA_DIRS"
    export XCURSOR_THEME="$(eval "echo $(gsettings get org.mate.peripherals-mouse cursor-theme)")"
    export XCURSOR_SIZE="$(gsettings get org.mate.peripherals-mouse cursor-size)"

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

    # Start systemd user services for graphical sessions
    systemctl --user start graphical-session.target

    # Wait for all components to exit and kill the server
    ${pkgs.mate.mate-session-manager}/bin/mate-session
    kill $SERVER_PID
  '';

  sessionPkg = pkgs.runCommand "mate-wayland-session" {
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

  backgroundPkg = pkgs.runCommand "mate-gtk-layer-background-autostart" {} ''
    mkdir -p "$out/share/applications/autostart"
    cat <<EOF > "$out/share/applications/mate-gtk-layer-background.desktop"
    [Desktop Entry]
    Name=MATE Wayland Background
    Exec=${pkgs.writeShellScript "mate-gtk-layer-background" ''exec ${pkgs.nur.repos.ilya-fedin.gtk-layer-background}/bin/gtk-layer-background -i "$(eval "echo $(gsettings get org.mate.background picture-filename)")"''}
    TryExec=${pkgs.nur.repos.ilya-fedin.gtk-layer-background}/bin/gtk-layer-background
    Type=Application
    OnlyShowIn=MATE;
    X-MATE-Autostart-Phase=Desktop
    X-MATE-Autostart-Notify=true
    X-MATE-AutoRestart=true
    X-MATE-Provides=filemanager
    NoDisplay=true
    EOF
  '';

  nixos-gsettings-desktop-schemas = let
    defaultPackages = with pkgs; [ mate.mate-session-manager mate.mate-panel ];
  in
  pkgs.runCommand "nixos-gsettings-desktop-schemas" {} ''
    mkdir -p $out/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas

    ${concatMapStrings
      (pkg: "cp -rf ${pkg}/share/gsettings-schemas/*/glib-2.0/schemas/*.xml $out/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas\n")
      defaultPackages}

    chmod -R a+w $out/share/gsettings-schemas/nixos-gsettings-overrides
    cat - > $out/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas/nixos-defaults.gschema.override <<- EOF
      [org.mate.session]
      required-components-list=['panel', 'filemanager', 'dock']

      [org.mate.session.required-components]
      filemanager='mate-gtk-layer-background'

      [org.mate.panel]
      disabled-applets=['NotificationAreaAppletFactory::NotificationArea', 'WnckletFactory::WorkspaceSwitcherApplet', 'WnckletFactory::ShowDesktopApplet']
    EOF

    ${pkgs.glib.dev}/bin/glib-compile-schemas $out/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas/
  '';
in {
  options = {
    programs.mate-wayland = {
      enable = mkOption {
        type = types.bool;
        default = false;
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
    environment.systemPackages = [ startSessionScript backgroundPkg ];
    environment.sessionVariables.NIX_GSETTINGS_OVERRIDES_DIR = "${nixos-gsettings-desktop-schemas}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas";
    i18n.inputMethod.enabled = "fcitx5";
  };
}
