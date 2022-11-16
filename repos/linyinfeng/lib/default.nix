{ lib }:

{
  versionDiff = import ./version-diff.nix { inherit lib; };
  makePackages = import ./make-packages.nix { inherit lib; };
  makeApps = import ./make-apps.nix { inherit lib; };
  appNames = import ./app-names.nix { inherit lib; };
}
