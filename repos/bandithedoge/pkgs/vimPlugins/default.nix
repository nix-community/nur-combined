{pkgs, ...}: let
  sources = import ./nix/_sources.nix;
in
  (pkgs.lib.makeExtensible (_:
    pkgs.lib.attrsets.mapAttrs'
    (name: src: let
      sanitizedName =
        builtins.replaceStrings
        ["."] ["-"]
        (pkgs.lib.strings.sanitizeDerivationName name);
    in
      pkgs.lib.attrsets.nameValuePair
      sanitizedName
      (pkgs.vimUtils.buildVimPlugin {
        pname = sanitizedName;
        version = src.rev;
        inherit src;
      }))
    sources))
  .extend (import ./_overrides.nix {inherit pkgs;})
