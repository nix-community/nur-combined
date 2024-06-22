{ lib, ... }:

with lib;
with builtins;

rec {
  # TODO: Fix recursive
  getFiles = { dir, suffixes ? [ ], recursive ? false, allow_default ? true }:
    let
      hasDefault = d: hasAttr "default.nix" (readDir (dir + "/${d}"));
      isImportable = name: kind:
        if kind == "directory" then
          recursive || (allow_default && hasDefault name)
        else
          lists.any (v: hasSuffix v name) suffixes;
      files = attrNames (filterAttrs isImportable (readDir dir));
    in map (f: dir + "/${f}") files;

  getNixFiles = dir:
    getFiles {
      inherit dir;
      suffixes = [ "nix" ];
    };

  getTomlFiles = dir:
    getFiles {
      inherit dir;
      suffix = [ "toml" ];
      recursive = true;
    };

  getNixTomlJsonFiles = dir:
    getFiles {
      inherit dir;
      suffixes = [ "nix" "toml" "json" ];
      recursive = true;
    };

  mapTOMLConfig = { options, config, pkgs }:
    let
      # ofPkgs :: String -> package
      # TODO: Make this fallible, problem is that getAttrFromPath aborts
      ofPkgs = p: getAttrFromPath (splitString "." p) pkgs;

      # validOrPkgs :: Type -> Value -> Value
      validOrPkgs = type: value: if type.check value then value else ofPkgs value;

      # fixTypes :: Type -> Value -> Value
      fixTypes = type: value:
        if type.name == "package" || type.description == "package" || type.functor.name == "package" then 
          ofPkgs value
        else if type.name == "path" then
          validOrPkgs type value
        # else if type.description == "package or string" then
          # Bandaid fix for `systemd.services.<name>.path`
          # ofPkgs value
        else if type.name == "nullOr" then
          # Can't define a null value as TOML doesn't have it
          # so we unconditionally use the nested type
          fixTypes type.nestedTypes.elemType value
        else if type.name == "listOf" then
          map (fixTypes type.nestedTypes.elemType) value
        else if type.name == "attrsOf" then
          mapAttrs (name: fixTypes type.nestedTypes.elemType) value
        else if type.name == "submodule" then
          recurseAttrs (type.getSubOptions []) value
        else if type.nestedTypes == {} then
          # Leaf type, doesn't contain anything
          value
        else 
          # Unrecognised container type, may break our evaluation!
          trace ("Warning: The conversion function from TOML does not recognise the following container type: "
               + "${type.description}. "
               + "This may break your configuration if you are relying on this conversion.") value;

      # recurseAttrs :: Attrs -> String -> Value -> Value
      fixAttrs = popt: name: set:
        if isOption popt.${name} then
          fixTypes popt.${name}.type set
        else
          recurseAttrs popt.${name} set;

      # recurseAttrs :: Attrs -> Attrs -> Attrs
      recurseAttrs = opt: set: mapAttrs (fixAttrs opt) set;
    in recurseAttrs options config;

  importToml =
    # The path of the TOML file that should be mapped into an importable NixOS module.
    path:

    # Already take arguments for module here so
    # we don't have to pass them up through the gazillion functions.
    { pkgs, options, ... }: {
      config = let
        rawSet = fromTOML (readFile path);
        config = addErrorContext
          "while parsing TOML file '${path}' (try fixing your syntax):" rawSet;
        mapped = mapTOMLConfig { inherit options config pkgs; };
      in addErrorContext
      "while doing special processing on TOML file '${path}':" mapped;

      # Set the file that generates this module, useful for debugging.
      # `nixos-rebuild` uses this to tell you where an error occurred like so:
      # … while evaluating definitions from `/nix/store/1wgf129l46kvrcnac6bsfazjf08df54f-fonts.toml':
      _file = path;
    };

  # Very similar to `importToml`.
  importJson =
    path: { pkgs, options, ... }:
      let
        rawSet = fromJSON (readFile path);
        config = addErrorContext
          "while parsing JSON file '${path}' (try fixing your syntax):" rawSet;
        mapped = mapTOMLConfig { inherit options config pkgs; };
      in {
      config = addErrorContext
      "while doing special processing on JSON file '${path}':" mapped;

      _file = path;
    };

  importFileWithHandler = methods: file:
    let
      unsupportedType = throw
        "Unrecognized module file type '${file}', allowed: ${attrNames methods}";
      suffix = findFirst (a: hasSuffix a file) unsupportedType
        (attrNames methods);
      method = methods.${suffix} or unsupportedType;
    in method file;
  defaultHandlers = {
    nix = lib.id; # NixOS module system imports Nix files itself.
    toml = importToml;
    json = importJson;
  };
}
