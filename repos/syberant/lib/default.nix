{ lib, ... }:

with lib;
with builtins;

rec {
  getFiles = { dir, suffix ? null, recursive ? false, allow_default ? true }:
    let
      hasDefault = d: hasAttr "default.nix" (readDir (dir + "/${d}"));
      isImportable = name: kind:
        if kind == "directory" then
          recursive || (allow_default && hasDefault name)
        else
          suffix == null || hasSuffix suffix name;
      files = attrNames (filterAttrs isImportable (readDir dir));
    in map (f: dir + "/${f}") files;

  getNixFiles = dir:
    getFiles {
      inherit dir;
      suffix = "nix";
    };

  getTomlFiles = dir:
    getFiles {
      inherit dir;
      suffix = "toml";
      recursive = true;
    };

  importToml =
    # The path of the TOML file that should be mapped into an importable NixOS module.
    path:

    # Already take arguments for module here so
    # we don't have to pass them up through the gazillion functions.
    { pkgs, options, ... }:

    let
      # getNestedAttr :: Attr -> [ String ] -> Option<Any>
      getNestedAttr = foldl' (state: arg: state.${arg} or null);
      # ofPkgs :: String -> package
      ofPkgs = p:
        let package = getNestedAttr pkgs (splitString "." p);
        in if package == null then
          throw
          "Could not unpack `pkgs.${p}` declared in a TOML file, pkgs doesn't have that attribute."
        else
          package;

      # Does special processing so strings can be used to configure options requiring packages.
      mapTypeLeaf = { value, opts }:
        let
          type = opts.type or null;
          description = type.description or null;
        in if type == types.package then
        # value :: package
          ofPkgs value
        else if description == "list of packages" then
        # TODO: proper typechecking, Nix's equality operator doesn't work here
        # value :: [ package ]
          map ofPkgs value
        else if description == "list of paths" then
        # TODO: proper typechecking, Nix's equality operator doesn't work here
        # value :: [ path ]
        # Used by some (e.g. fonts.fonts) instead of `listOf packages`
          map ofPkgs value
        else
        # Some other type, no need to use pkgs here.
          value;

      # Recursively call special processing
      mapTOMLConfig = set:
        let
          rec_map = name_path: value:
            mapTypeLeaf {
              inherit value;
              opts = getNestedAttr options name_path;
            };
        in mapAttrsRecursive rec_map set;
    in {
      config = let
        rawSet = fromTOML (readFile path);
        set = addErrorContext
          "while parsing TOML file '${path}' (try fixing your syntax):" rawSet;
        mapped = mapTOMLConfig set;
      in addErrorContext
      "while doing special processing on TOML file '${path}':" mapped;

      # Set the file that generates this module, useful for debugging.
      # `nixos-rebuild` uses this to tell you where an error occurred like so:
      # … while evaluating definitions from `/nix/store/1wgf129l46kvrcnac6bsfazjf08df54f-fonts.toml':
      _file = path;
    };

}
