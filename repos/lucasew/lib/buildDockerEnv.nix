{ mkShell
, writeShellScript
, writeShellScriptBin
, bash
, nix
, lib
, ...
}:
{ name ? "docker-env"
, cr ? "docker"
, ...
} @ args:
let
  shellArgs = builtins.removeAttrs args ["name" "cr"];
  shell = mkShell (shellArgs // {
    buildInputs = shellArgs.buildInputs or [] ++ [ nix ];
  });
  containerScript = writeShellScript name
  (let
    shellScript = builtins.readFile shell;
    shellScript' = lib.splitString "\n" shellScript;
    shellScript'' = builtins.filter (line: builtins.match "^declare[^$]*" line != null) shellScript';
    shellScript''' = builtins.concatStringsSep "\n" shellScript'';
  in ''
    ${shellScript'''}
    HOME=/app
    mkdir /app -p
    cd /app
    "$@"
  '');
in writeShellScriptBin name ''
  ARGS=()
  if [ $# -gt 0 ]; then
    ARGS+=(-ti)
    while [ $# -gt 0 ]; do
      if [ "$1" == "--" ]; then
        shift
        break
      fi
      ARGS+=("$1")
      shift
    done
  fi
  # for arg in ${"$"}{ARGS[@]}; do
  #   echo arg: $arg
  # done
  ${cr} run ${"$"}{ARGS[@]} -v /nix:/nix:ro alpine ${containerScript} "$@"
''
