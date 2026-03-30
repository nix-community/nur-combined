{
  nixpkgs ? <nixpkgs>,
}:
pkgs: func:
let
  # helpers
  try =
    e:
    let
      res = builtins.tryEval e;
    in
    if res.success then res.value else null;

  # get all images that support the current system
  images = pkgs.lib.filterAttrs (
    _: image:
    (!pkgs.lib.attrsets.hasAttrByPath [ "meta" "platforms" ] image)
    || (builtins.elem pkgs.stdenv.buildPlatform.system image.meta.platforms)
  ) (func pkgs);

  # pkgs for cross-compilation
  mkCrossPkgs =
    crossSystem:
    (import nixpkgs {
      localSystem = pkgs.stdenv.buildPlatform.system;
      inherit crossSystem;
      inherit (pkgs) config overlays;
    });

  pkgs-x86_64-linux = mkCrossPkgs {
    config = "x86_64-unknown-linux-musl";
    isStatic = true;
  };
  pkgs-aarch64-linux = mkCrossPkgs {
    config = "aarch64-unknown-linux-musl";
    isStatic = true;
  };
  pkgs-armv7l-linux = mkCrossPkgs {
    config = "armv7l-unknown-linux-musleabihf";
    isStatic = true;
  };
  pkgs-armv6l-linux = mkCrossPkgs {
    config = "armv6l-unknown-linux-musleabihf";
    isStatic = true;
  };

  # tries to create an image for a given pkgs set
  mkImage = name: pkgs: try ((func pkgs).${name});

  # make sure the main package for the image is available for its hostPlatform
  mkImageIf =
    name: package: pkgs:
    if pkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform package then mkImage name pkgs else null;
in

builtins.mapAttrs (
  name: image:
  let
    package = image.package or null;
  in
  if package == null then
    image.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            x86_64-linux = mkImage name pkgs-x86_64-linux;
            aarch64-linux = mkImage name pkgs-aarch64-linux;
            armv7l-linux = mkImage name pkgs-armv7l-linux;
            armv6l-linux = mkImage name pkgs-armv6l-linux;
          };
      }
    )
  else
    image.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            x86_64-linux = mkImageIf name package pkgs-x86_64-linux;
            aarch64-linux = mkImageIf name package pkgs-aarch64-linux;
            armv7l-linux = mkImageIf name package pkgs-armv7l-linux;
            armv6l-linux = mkImageIf name package pkgs-armv6l-linux;
          };
      }
    )
) images
