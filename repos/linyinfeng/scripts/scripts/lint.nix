{ writeShellScriptBin, fd, nix-linter }:

writeShellScriptBin "lint" ''
  ${fd}/bin/fd '.*\.nix' --exec ${nix-linter}/bin/nix-linter
''
