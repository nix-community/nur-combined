{ }:
pkgs: imagesFunc:
let
  base-pkgs = imagesFunc pkgs;

  # Images are always built for linux, so we only need to consider the architecture.
  aarch64-pkgs = imagesFunc pkgs.pkgsCross.aarch64-multiplatform;
  x86_64-pkgs = imagesFunc pkgs.pkgsCross.musl64;
  armv7l-pkgs = imagesFunc pkgs.pkgsCross.armv7l-hf-multiplatform;
  armv6l-pkgs = imagesFunc pkgs.pkgsCross.raspberryPi;
in
builtins.mapAttrs (
  name: image:
  let
    pkg = image.pkg or null;
  in
  if pkg == null then
    image
  else
    image.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            x86_64-linux = if pkg ? x86_64-linux then x86_64-pkgs.${name} else null;
            aarch64-linux = if pkg ? aarch64-pkgs-linux then aarch64-pkgs.${name} else null;
            armv7l-linux = if pkg ? armv7l-linux then armv7l-pkgs.${name} else null;
            armv6l-linux = if pkg ? armv6l-linux then armv6l-pkgs.${name} else null;
          };
      }
    )
) base-pkgs
