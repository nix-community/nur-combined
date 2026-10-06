{
  lib,
  callPackage,
  runCommand,
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
    let
      duckdb = callPackage ./default.nix { ${"with${toPascalCase name}"} = true; };
    in
    # loadable extensions share the default core, the wrapper loads each extension
    if duckdb ? unwrapped then
      duckdb
    else
      duckdb.overrideAttrs (
        _finalAttrs: previousAttrs: {
          pname = "${previousAttrs.pname}-extension-${name}";
          doInstallCheck = false;
        }
      );
in

lib.listToAttrs (
  map (name: lib.nameValuePair "duckdb-extension-${name}" (mkExtensionCheck name)) extensionNames
)
// {
  duckdb-link-archives =
    let
      duckdb = callPackage ./default.nix { };
    in
    runCommand "duckdb-link-archives" { } ''
      for archive in ${lib.escapeShellArgs duckdb.link.static.archives}; do
        if [ ! -f "$archive" ]; then
          echo "missing archive: $archive" >&2
          exit 1
        fi
      done
      touch $out
    '';
}
