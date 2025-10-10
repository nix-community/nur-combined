{
  writeShellApplication,
  systemd,
  gawk,
  procps,
  lib,
}:
let
  script = writeShellApplication {
    name = "claude-desktop-toggle";

    runtimeInputs = [
      systemd
      gawk
      procps
    ];

    text = ''
      set +e

      # Find Claude Desktop PID
      CLAUDE_PID=$(pgrep -f "electron.*claude-desktop/resources/app.asar" | head -1)

      if [ -z "$CLAUDE_PID" ]; then
          # Claude is not running, start it
          claude-desktop &
          exit 0
      fi

      # Find the bus name corresponding to the PID
      CLAUDE_BUS=$(busctl --user list | awk -v pid="$CLAUDE_PID" '$2 == pid && $1 ~ /^:1\.[0-9]+$/ {print $1; exit}')

      if [ -z "$CLAUDE_BUS" ]; then
          echo "Could not find D-Bus name for Claude" >&2
          exit 1
      fi

      # Toggle window via DBusMenu Event
      dbus-send --session --print-reply \
        --dest="$CLAUDE_BUS" \
        /com/canonical/dbusmenu \
        com.canonical.dbusmenu.Event \
        int32:1 string:"clicked" variant:int32:0 uint32:0
    '';
  };
in
script.overrideAttrs (oldAttrs: {
  version = "1.0.0";
  meta =
    with lib;
    oldAttrs.meta or { }
    // {
      description = "Utility for quickly opening Claude Desktop when minimized to tray";
      license = licenses.gpl3Plus;
      maintainers = [ maintainers.aciceri ];
      # mainProgram is set automatically by writeShellApplication
    };
})
