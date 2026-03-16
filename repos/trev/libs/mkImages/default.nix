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
  ) (func pkgs-default);

  # overlay to create images
  mkImage = _: prev: {
    mkImage = import ./mkImage.nix {
      system = pkgs.stdenv.buildPlatform.system;
      pkgs = prev;
    };
  };

  # pkgs for cross-compilation
  mkCrossPkgs =
    crossSystem:
    (import nixpkgs {
      localSystem = pkgs.stdenv.buildPlatform.system;
      inherit crossSystem;
      inherit (pkgs) config;
      overlays = pkgs.overlays ++ [ mkImage ];
    });
  pkgs-default = pkgs.appendOverlays [ mkImage ];
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

  # tries to create the cross-compiled image
  mkPackage = crossPkgs: name: try ((func crossPkgs).${name});
in

builtins.mapAttrs (
  name: image:
  let
    package = image.pkg or null;
    hasPlatform =
      crossPkgs:
      if builtins.hasAttr crossPkgs.stdenv.hostPlatform.system package then
        mkPackage crossPkgs name
      else
        null;
  in
  if package == null then
    image
  else
    image.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            amd64 = hasPlatform pkgs-x86_64-linux;
            arm64 = hasPlatform pkgs-aarch64-linux;
            arm = hasPlatform pkgs-armv7l-linux;
          };
      }
    )
) images
