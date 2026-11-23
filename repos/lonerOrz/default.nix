{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  dir ? ./pkgs,
  pkgFileName ? "default.nix",
}:

let
  inherit (pkgs) lib;

  entries = builtins.readDir dir;
  excludedNames = [ ];

  resolve =
    name:
    let
      type = entries.${name};
      path = dir + "/${name}";

      isNixFile = type == "regular" && lib.hasSuffix ".nix" name;
      isDirectory = type == "directory";

      file = if isNixFile then path else path + "/${pkgFileName}";
    in
    if lib.elem name excludedNames then
      null
    else if isNixFile then
      {
        name = lib.removeSuffix ".nix" name;
        inherit file;
      }
    else if isDirectory && builtins.pathExists file then
      {
        inherit name file;
      }
    else
      null;

  resolved = lib.filter (entry: entry != null) (map resolve (builtins.attrNames entries));

  duplicateNames = lib.attrNames (
    lib.filterAttrs (_: group: builtins.length group > 1) (lib.groupBy (entry: entry.name) resolved)
  );

  defaultUpdateScript = pkgs.nix-update-script { };

  addMetadata =
    drv: file:
    if lib.isDerivation drv && drv ? overrideAttrs then
      drv.overrideAttrs (
        old:
        let
          passthru = old.passthru or { };

          hasUpdateScript =
            (old ? updateScript) || ((old.meta or { }) ? updateScript) || (passthru ? updateScript);

          autoUpdate = old.autoUpdate or (passthru.autoUpdate or true);
        in
        {
          passthru =
            passthru
            // {
              updateFile = file;
            }
            // lib.optionalAttrs (!hasUpdateScript && autoUpdate != false) {
              updateScript = defaultUpdateScript;
            };
        }
      )
    else
      drv;

  packageScope = pkgs // packages;

  packages =
    if duplicateNames != [ ] then
      throw ''
        default.nix: duplicate package names detected:
        ${lib.concatStringsSep ", " duplicateNames}
      ''
    else
      builtins.listToAttrs (
        map (entry: {
          name = entry.name;
          value = addMetadata (lib.callPackageWith packageScope entry.file { }) entry.file;
        }) resolved
      );

in
packages
