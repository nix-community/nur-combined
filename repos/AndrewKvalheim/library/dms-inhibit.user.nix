{ lib, pkgs, ... }:

let
  inherit (lib) getExe;
  inherit (pkgs) socat writeShellApplication;

  dms-inhibit = writeShellApplication {
    name = "dms-inhibit";
    runtimeInputs = [ socat ];
    text = ''
      socket="$XDG_RUNTIME_DIR/dms-inhibit.sock"

      send() { local request="$1"
        local response; response="$(<<<"$request" socat - "UNIX-CONNECT:$socket")"
        case "$response" in
          'error') echo "dms-inhibit: Error: ''${request@A} ''${response@A}" >&2; exit 1;;
          'ok');;
          'token '*) echo "''${response#token *}";;
          *) echo "dms-inhibit: Not implemented for response: ''${request@A} ''${response@A}" >&2; exit 1;;
        esac
      }

      token="$(send 'hold')"
      trap 'trap - EXIT INT TERM; send "release $token"' EXIT INT TERM
      "$@"
    '';
  };

  handle-dms-inhibit = writeShellApplication {
    name = "handle-dms-inhibit";
    text = ''
      shopt -s nullglob
      umask '077'

      holds_dir="$XDG_RUNTIME_DIR/dms-inhibit"

      handle_hold() {
        local token; token="$(</proc/sys/kernel/random/uuid)"

        echo "Hold: $token" >&2
        mkdir --parents "$holds_dir"
        touch "$holds_dir/$token"
        dms ipc call inhibit enable >&2

        echo "token $token"
      }

      handle_release() { local token="$1"
        if [[ ! -e "$holds_dir/$token" ]]; then
          echo "Nonexistent hold: ''${token@A}" >&2
          return 1
        fi

        echo "Release hold: $token" >&2
        rm "$holds_dir/$token"
        echo 'ok'

        local holds=("$holds_dir/"*)
        echo "Remaining holds: ''${#holds[@]}" >&2

        if (( ''${#holds[@]} == 0 )); then
          dms ipc call inhibit disable >&2
        fi
      }

      read -r request
      case "$request" in
        'release '*) handle_release "''${request#release *}" || echo 'error';;
        'hold') handle_hold || echo 'error';;
        *) echo "Not implemented for request: ''${request@A}" >&2; echo 'error';;
      esac
    '';
  };
in
{
  systemd.user.sockets.dms-inhibit = {
    Install.WantedBy = [ "sockets.target" ];
    Socket = {
      Accept = true;
      ListenStream = "%t/dms-inhibit.sock";
      SocketMode = "0600";
    };
  };

  systemd.user.services."dms-inhibit@" = {
    Unit = {
      Requisite = [ "dms.service" ];
      After = [ "dms.service" ];
    };
    Service = {
      Type = "oneshot";
      StandardInput = "socket";
      StandardOutput = "socket";
      StandardError = "journal";
      ExecStart = getExe handle-dms-inhibit;
    };
  };

  home.packages = [ dms-inhibit ];
}
