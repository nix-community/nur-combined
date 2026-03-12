{ }:
pkgs: packageFunc:
let
  base-pkgs = packageFunc pkgs;
  x86_64-linux-pkgs = packageFunc pkgs.pkgsCross.musl64;
  x86_64-darwin-pkgs = packageFunc pkgs.pkgsCross.x86_64-darwin;
  x86_64-windows-pkgs = packageFunc pkgs.pkgsCross.x86_64-windows;
  aarch64-linux-pkgs = packageFunc pkgs.pkgsCross.aarch64-multiplatform;
  aarch64-darwin-pkgs = packageFunc pkgs.pkgsCross.aarch64-darwin;
  aarch64-windows-pkgs = packageFunc pkgs.pkgsCross.mingw-ucrt-aarch64;
  armv7l-linux-pkgs = packageFunc pkgs.pkgsCross.armv7l-hf-multiplatform;
  armv6l-linux-pkgs = packageFunc pkgs.pkgsCross.raspberryPi;
in
builtins.mapAttrs (
  name: package:
  package.overrideAttrs (
    _: prev: {
      passthru = prev.passthru // {
        x86_64-linux = x86_64-linux-pkgs.${name};
        x86_64-darwin = x86_64-darwin-pkgs.${name};
        x86_64-windows = x86_64-windows-pkgs.${name};
        aarch64-linux = aarch64-linux-pkgs.${name};
        aarch64-darwin = aarch64-darwin-pkgs.${name};
        aarch64-windows = aarch64-windows-pkgs.${name};
        armv7l-linux = armv7l-linux-pkgs.${name};
        armv6l-linux = armv6l-linux-pkgs.${name};
      };
    }
  )
) base-pkgs
