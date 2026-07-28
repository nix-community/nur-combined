{ pkgs, ... }: {
  vacu.shell.idempotentShellLines = ''
    if [[ -z "''${VACU_HISTORY_SESSION_ID-}" ]]; then
      VACU_HISTORY_SESSION_ID="$(${pkgs.libossp_uuid}/bin/uuid)"
    fi
    VACU_HISTORY_DB_PATH="$HOME/vacu-shell-history.sqlite"
    if [[ -e $VACU_HISTORY_DB_PATH ]]; then
      declare db_mode
      db_mode="$(stat -c '%a' "$VACU_HISTORY_DB_PATH")"
      if [[ $db_mode != 600 ]]; then
        echo "Warning: access mode on $VACU_HISTORY_DB_PATH is bad, expected 600, is $db_mode" >&2
      fi
      unset db_mode
    fi
    function vacu_history_record() {
      LC_ALL=C HISTTIMEFORMAT='%S|%M|%H|%d|%m|%Y|%w|%j|%z|' history 1 | VACU_HISTORY_SESSION_ID="$VACU_HISTORY_SESSION_ID" VACU_HISTORY_DB_PATH="$VACU_HISTORY_DB_PATH" ${pkgs.vacu-history}/bin/vacu-history
    }
    PS0='$(vacu_history_record >/dev/null)'"$PS0"
  '';
}
