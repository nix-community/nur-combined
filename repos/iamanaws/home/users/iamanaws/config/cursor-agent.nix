{
  config,
  hostConfig,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # The agent follows XDG_CONFIG_HOME on Linux and uses ~/.cursor otherwise
  file =
    if pkgs.stdenv.hostPlatform.isLinux && config.xdg.enable then
      "${config.xdg.configHome}/cursor/cli-config.json"
    else
      "${config.home.homeDirectory}/.cursor/cli-config.json";

  settings = {
    # No Cursor trailer on commits, no Cursor footer on pull requests
    attribution = {
      attributeCommitsToAgent = false;
      attributePRsToAgent = false;
    };
  };

  # Fields the agent requires in a new file
  defaults = {
    version = 1;
    editor.vimMode = false;
    permissions = {
      allow = [ ];
      deny = [ ];
    };
  };

  jq = lib.getExe pkgs.jq;
in
lib.optionalAttrs hostConfig.isGraphical {
  home.packages = [ inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.cursor-agent ];

  # The agent keeps its login and state in this file, so merge into it
  home.activation.cursorAgentConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    file=${lib.escapeShellArg file}
    settings=${lib.escapeShellArg (builtins.toJSON settings)}

    if [ ! -f "$file" ]; then
      current=${lib.escapeShellArg (builtins.toJSON defaults)}
    elif ! current=$(${jq} . "$file"); then
      warnEcho "Skipping $file, it is not valid JSON"
      current=
    fi

    if [ -n "$current" ]; then
      merged=$(${jq} --argjson settings "$settings" '. * $settings' <<< "$current")
      if [ ! -f "$file" ] || [ "$merged" != "$current" ]; then
        run mkdir -p "$(dirname "$file")"
        run tee "$file" <<< "$merged" > /dev/null
      fi
    fi
  '';
}
