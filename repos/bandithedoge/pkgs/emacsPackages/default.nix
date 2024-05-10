{pkgs, ...}: let
  sources = import ./nix/_sources.nix {inherit pkgs;};
in
  (pkgs.lib.makeExtensible (_:
    pkgs.lib.attrsets.mapAttrs'
    (name: src: let
      sanitizedName = pkgs.lib.pipe name [
        (pkgs.lib.removeSuffix ".el")
        (builtins.replaceStrings ["."] ["-"])
        pkgs.lib.strings.sanitizeDerivationName
      ];
    in
      pkgs.lib.attrsets.nameValuePair
      sanitizedName
      (pkgs.emacsPackages.melpaBuild {
        pname = sanitizedName;
        # TODO: set version properly
        # https://github.com/nmattia/niv/issues/111
        version = "0";
        inherit src;
        commit = src.rev;

        recipe = pkgs.writeText "recipe" ''
          (${sanitizedName}
            :repo "${src.owner}/${src.repo}"
            :fetcher github)
        '';
      }))
    (pkgs.lib.filterAttrs (_: v: pkgs.lib.isStorePath v) sources)))
  .extend (import ./_overrides.nix {inherit pkgs;})
