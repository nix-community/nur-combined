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
  let
    platforms = package.meta.platforms or [ ];
  in
  if builtins.length platforms == 0 then
    package
  else
    package.overrideAttrs (
      _: prev: {
        passthru = prev.passthru // {
          x86_64-linux =
            let
              cross = x86_64-linux-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          x86_64-darwin =
            let
              cross = x86_64-darwin-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          x86_64-windows =
            let
              cross = x86_64-windows-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          aarch64-linux =
            let
              cross = aarch64-linux-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          aarch64-darwin =
            let
              cross = aarch64-darwin-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          aarch64-windows =
            let
              cross = aarch64-windows-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          armv7l-linux =
            let
              cross = armv7l-linux-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;

          armv6l-linux =
            let
              cross = armv6l-linux-pkgs.${name};
            in
            if builtins.elem cross.stdenv.hostPlatform.system platforms then cross else null;
        };
      }
    )
) base-pkgs
