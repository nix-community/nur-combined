{
  pkgs ? import <nixpkgs> {},
  sources ? import ./nix/sources.nix,
}:
pkgs.lib.makeExtensible (_:
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
    sources)
