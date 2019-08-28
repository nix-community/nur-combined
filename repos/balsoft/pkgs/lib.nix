{
  callPackageDouble = pkgs: name:
    pkgs.callPackage "${(import (../nix/sources.nix)).${name}}/${name}.nix" { };
}
