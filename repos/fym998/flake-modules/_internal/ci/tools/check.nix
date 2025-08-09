{ writeShellScriptBin, nix-fast-build }:
writeShellScriptBin "check" "${nix-fast-build}/bin/nix-fast-build --no-nom"
