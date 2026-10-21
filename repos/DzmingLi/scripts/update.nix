{
  lib,
  writeShellApplication,
  writeText,
  nushell,
  nix,
  git,
  runCommand,
  packages,
}:
let
  updatable = lib.filterAttrs (
    _: package: lib.isDerivation package && package ? updateScript
  ) packages;
  commandFile =
    attribute: package:
    let
      script = package.updateScript;
    in
    writeText "update-${attribute}.json" (
      builtins.toJSON {
        inherit attribute;
        attrPath = script.attrPath or attribute;
        name = package.name;
        pname = lib.getName package;
        oldVersion = lib.getVersion package;
        command = map toString (lib.toList (script.command or script));
      }
    );
in
writeShellApplication {
  name = "update-packages";
  runtimeInputs = [
    nushell
    nix
    git
  ];
  text = ''exec nu ${./update-packages.nu} "$@"'';
  passthru = {
    packageNames = builtins.attrNames updatable;
    # Building a selected JSON file realizes that script's tool dependencies,
    # without building the application or unrelated packages' update tools.
    commands = lib.mapAttrs commandFile updatable;
    tests.transactions =
      runCommand "package-update-transactions"
        {
          nativeBuildInputs = [
            nushell
            git
          ];
        }
        ''
          cp -r ${./.} scripts
          chmod -R u+w scripts
          nu scripts/tests/update-packages.nu
          touch $out
        '';
  };
}
