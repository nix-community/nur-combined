{ mkShell
, writeShellScriptBin
, writeShellScript
, bash
, nix
, ...
}:
{ name ? "docker-env"
, runCommand ? "${bash}/bin/bash"
, cr ? "docker"
, ...
} @ args:
let
  shellArgs = builtins.removeAttrs args ["name" "runCommand" "cr"];
  shell = mkShell (shellArgs // {
    buildInputs = shellArgs.buildInputs or [] ++ [ nix ];
  });
  containerScript = writeShellScript name ''
    ${builtins.readFile shell}
    HOME=/app
    mkdir /app -p
    ${runCommand}
  '';
in writeShellScriptBin name ''
  ${cr} run -ti -v /nix:/nix:ro alpine ${containerScript}
''
  
