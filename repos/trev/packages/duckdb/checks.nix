{
  lib,
  callPackage,
}:

let
  extensionNames = lib.pipe (builtins.readDir ./extensions) [
    (lib.filterAttrs (
      name: type:
      type == "regular"
      && lib.hasSuffix ".nix" name
      && !(builtins.elem name [
        "default.nix"
        "generic.nix"
      ])
    ))
    builtins.attrNames
    (map (lib.removeSuffix ".nix"))
  ];

  toPascalCase =
    name:
    lib.concatMapStrings (
      part:
      lib.toUpper (builtins.substring 0 1 part)
      + builtins.substring 1 (builtins.stringLength part - 1) part
    ) (lib.splitString "-" name);

  mkExtensionCheck =
    name:
    (callPackage ./default.nix { ${"with${toPascalCase name}"} = true; }).overrideAttrs (
      _finalAttrs: previousAttrs: {
        pname = "${previousAttrs.pname}-extension-${name}";
        doInstallCheck = false;
      }
    );
in

lib.listToAttrs (
  map (name: lib.nameValuePair "duckdb-extension-${name}" (mkExtensionCheck name)) extensionNames
)
