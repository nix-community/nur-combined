{ writeScriptBin }:

writeScriptBin "use-udo" ''
  #!/usr/bin/env -S sh -c 'echo "Usage: . $0" >&2; exit 1'

  # Re-run self via `sudo` and provide `udo` (“user do”) function
  if [[ -z "''${SUDO_USER:-}" ]]; then
    self=("$0" "$@")
    prompt="[sudo ''${self[*]}] password for %p: "
    udo='runuser --user "$SUDO_USER" -- env XDG_RUNTIME_DIR=''\'''${XDG_RUNTIME_DIR%Q}' "$@"'

    exec sudo  --prompt "$prompt" BASH_FUNC_udo%%="() { $udo; }" -- "''${self[@]}"
  fi
''
