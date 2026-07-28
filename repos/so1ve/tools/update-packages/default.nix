{
  lib,
  writeShellApplication,
}:

packages:

let
  updatablePackages = lib.filterAttrs (_: package: package ? updateScript) packages;
  renderCommand =
    updateScript:
    lib.escapeShellArgs (map toString (lib.toList (updateScript.command or updateScript)));
  commands = lib.mapAttrsToList (name: package: ''
    echo ${lib.escapeShellArg "Updating ${name}"}
    ${renderCommand package.updateScript}
  '') updatablePackages;
in
assert lib.assertMsg (commands != [ ]) "update-packages: no packages provide passthru.updateScript";
writeShellApplication {
  name = "update-packages";
  text = lib.concatStringsSep "\n" commands;
}
