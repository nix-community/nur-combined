{pkgs, ...}: let
  sources = import ./nix/_sources.nix;
in
  (pkgs.lib.makeExtensible (_:
    pkgs.lib.attrsets.mapAttrs'
    (name: src: let
      sanitizedName =
        pkgs.lib.strings.sanitizeDerivationName
        (pkgs.lib.removeSuffix ".xplr" name);
    in
      pkgs.lib.attrsets.nameValuePair
      sanitizedName
      (pkgs.stdenv.mkDerivation {
        pname = name;
        version = src.rev;
        inherit src;
        buildPhase = ''
          cp -r ${src} $out
        '';
      }))
    sources))
  .extend (import ./_overrides.nix {inherit pkgs;})
