{ }:
startPkgs: packageFunc:
let
  base-pkgs = packageFunc startPkgs;
  aarch64-linux-pkgs = packageFunc startPkgs.pkgsCross.aarch64-multiplatform;
  aarch64-darwin-pkgs = packageFunc startPkgs.pkgsCross.aarch64-darwin;
  aarch64-windows-pkgs = packageFunc startPkgs.pkgsCross.mingw-ucrt-aarch64;
  x86_64-linux-pkgs = packageFunc startPkgs.pkgsCross.musl64;
  x86_64-darwin-pkgs = packageFunc startPkgs.pkgsCross.x86_64-darwin;
  x86_64-windows-pkgs = packageFunc startPkgs.pkgsCross.x86_64-windows;
in
builtins.mapAttrs (
  name: package:
  package.overrideAttrs (
    _: prev: {
      passthru = prev.passthru // {
        aarch64-linux = aarch64-linux-pkgs.${name};
        aarch64-darwin = aarch64-darwin-pkgs.${name};
        aarch64-windows = aarch64-windows-pkgs.${name};
        x86_64-linux = x86_64-linux-pkgs.${name};
        x86_64-darwin = x86_64-darwin-pkgs.${name};
        x86_64-windows = x86_64-windows-pkgs.${name};
      };
    }
  )
) base-pkgs
