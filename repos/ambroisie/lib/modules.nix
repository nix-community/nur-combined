{ self, lib, ... }:
let
  inherit (builtins) readDir pathExists;
  inherit (lib) hasPrefix hasSuffix nameValuePair removeSuffix;
  inherit (self.attrs) mapFilterAttrs;

  implOptionalRecursion = recurse:
    let
      recurseStep =
        if recurse
        then (n: path: fn: nameValuePair n (impl path fn))
        else (_: _: _: nameValuePair "" null);
      impl = dir: fn:
        mapFilterAttrs
          (n: _: n != "" && !(hasPrefix "_" n))
          (n: v:
            let
              path = "${toString dir}/${n}";
            in
            if v == "directory"
            then
              if pathExists "${path}/default.nix"
              then nameValuePair n (fn path)
              else recurseStep n path fn
            else if v == "regular" && n != "default.nix" && hasSuffix ".nix" n
            then nameValuePair (removeSuffix ".nix" n) (fn path)
            else nameValuePair "" null)
          (readDir dir);
    in
    impl;
in
{
  # Find all nix modules in a directory, discard any prefixed with "_",
  # map a function to each resulting path, and generate an attribute set
  # to associate module name to resulting value.
  #
  # mapModules ::
  #   path
  #   (path -> any)
  #   attrs
  mapModules = implOptionalRecursion false;

  # Recursive version of mapModules.
  #
  # mapModulesRec ::
  #   path
  #   (path -> any)
  #   attrs
  mapModulesRec = implOptionalRecursion true;
}
