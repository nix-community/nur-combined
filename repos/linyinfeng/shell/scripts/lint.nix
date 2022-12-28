{ writeShellScriptBin, fd, nix-linter, python3Packages }:

(writeShellScriptBin "lint" ''
  ${fd}/bin/fd '.*\.nix' --exec ${nix-linter}/bin/nix-linter
'').overrideAttrs (old: {
  meta = old.meta // {
    broken = nix-linter.meta.broken;
  };
})
