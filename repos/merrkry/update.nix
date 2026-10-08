{
  pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
  },
}:

let
  inherit (pkgs) lib;
  nurLib = import ./lib { inherit pkgs; };
  packages = nurLib.getPackages (import ./default.nix { inherit pkgs; });

  metadata = lib.mapAttrs (
    _: package:
    let
      source = package.src or { };
    in
    {
      inherit (package) name version;
      pname = package.pname or (lib.getName package);
      changelog = package.meta.changelog or null;
      githubSource =
        if builtins.isAttrs source && source ? owner && source ? repo && source ? rev then
          {
            url = "https://github.com/${source.owner}/${source.repo}";
            inherit (source) rev;
          }
        else
          null;
      hasUpdateScript = package.updateScript or null != null;
      buildable = nurLib.isBuildable package;
      updatable = nurLib.isUpdatable package;
      tests = builtins.attrNames (package.passthru.tests or { });
    }
  ) packages;
in
{
  inventory = {
    system = pkgs.stdenv.hostPlatform.system;
    packages = metadata;
  };

  scripts = lib.mapAttrs (
    name: package:
    pkgs.writeShellScript "update-${name}" (
      lib.escapeShellArgs (lib.toList (package.updateScript.command or package.updateScript))
    )
  ) packages;

  tests = lib.mapAttrs (_: package: package.passthru.tests or { }) packages;

  builds = packages;

  derivations = lib.mapAttrs (_: package: {
    build = package.drvPath;
    tests = lib.mapAttrs (_: test: test.drvPath) (package.passthru.tests or { });
  }) packages;
}
