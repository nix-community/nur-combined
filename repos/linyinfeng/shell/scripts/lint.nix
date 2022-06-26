{ writeShellScriptBin, fd, nix-linter, python3Packages }:

(writeShellScriptBin "lint" ''
  ${fd}/bin/fd '.*\.nix' --exec ${nix-linter}/bin/nix-linter
'').overrideAttrs (old: {
  # TODO https://github.com/pyca/pyopenssl/issues/873
  meta = old.meta // {
    broken = python3Packages.pyopenssl.meta.broken;
  };
})
