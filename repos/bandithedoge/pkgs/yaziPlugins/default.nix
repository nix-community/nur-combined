{pkgs, ...}: let
  sources = import ./nix/_sources.nix {inherit pkgs;};
in
  (pkgs.lib.makeExtensible
    (_:
      pkgs.lib.mapAttrs' (name: src:
        pkgs.lib.nameValuePair
        (pkgs.lib.removeSuffix ".yazi" name)
        (pkgs.stdenv.mkDerivation {
          pname = name;
          version = src.rev;
          inherit src;
          buildPhase = ''
            cp -r ${src} $out
          '';
        }))
      (pkgs.lib.filterAttrs (_: v: pkgs.lib.isStorePath v) sources)))
  .extend (pkgs.callPackage ./_overrides.nix {})
