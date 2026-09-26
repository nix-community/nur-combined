let
  root = ./..;

  flake = builtins.getFlake (toString root);
  lib = flake.inputs.nixpkgs.lib;

  legacyPackages = flake.legacyPackages.${builtins.currentSystem};

  # Derivations expose their homepage through `meta`; everything else (e.g.
  # fetchers and builders, which are plain functions) must provide a sibling
  # `meta.nix`. Entries without a homepage are silently skipped.
  homepageOf = name: value:
    if lib.isDerivation value then
      let
        homepage = value.meta.homepage or null;
      in
      if homepage == null then
        throw "readme: package '${name}' is missing meta.homepage"
      else if lib.isList homepage then
        builtins.head homepage
      else
        homepage
    else
      let metaFile = root + "/pkgs/${name}/meta.nix"; in
      if builtins.pathExists metaFile then (import metaFile).homepage else null;

  lines = lib.concatMap
    (name:
      let homepage = homepageOf name legacyPackages.${name}; in
      lib.optional (homepage != null) "- [${name}](${homepage})")
    (builtins.attrNames legacyPackages);
in
lib.concatStringsSep "\n" lines
