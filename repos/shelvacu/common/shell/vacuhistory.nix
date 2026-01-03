{ pkgs, ... }:
{
  vacu.shell.idempotentShellLines = ''
    if [[ -z "''${VACU_HISTORY_SESSION_ID-}" ]]; then
      VACU_HISTORY_SESSION_ID="$(${pkgs.libossp_uuid}/bin/uuid)"
    fi
    VACU_HISTORY_DB_PATH="$HOME/vacu-shell-history.sqlite"
    function vacu_history_record() {
      LC_ALL=C HISTTIMEFORMAT='%S|%M|%H|%d|%m|%Y|%w|%j|%z|' history 1 | VACU_HISTORY_SESSION_ID="$VACU_HISTORY_SESSION_ID" VACU_HISTORY_DB_PATH="$VACU_HISTORY_DB_PATH" ${pkgs.vacu-history}/bin/vacu-history
    }
    PS0='$(vacu_history_record >/dev/null)'"$PS0"
  '';
}
