{
  nixpkgs ? <nixpkgs>,
}:
pkgs: func:
let
  try =
    e:
    let
      res = builtins.tryEval e;
    in
    if res.success then res.value else null;

  mkImage = _: prev: {
    mkImage = import ./mkImage.nix {
      system = pkgs.stdenv.buildPlatform.system;
      pkgs = prev;
    };
  };

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

  # Get all images that support the current system
  images = pkgs.lib.filterAttrs (
    _: image:
    (!pkgs.lib.attrsets.hasAttrByPath [ "meta" "platforms" ] image)
    || (builtins.elem pkgs.stdenv.buildPlatform.system (image.meta.platforms or [ ]))
  ) (func pkgs-default);
in
builtins.mapAttrs (
  name: image:
  let
    pkg = image.pkg or null;
    hasPlatform =
      platform: pkgsTarget:
      if builtins.hasAttr "${platform}" pkg then try ((func pkgsTarget).${name}) else null;
  in
  if pkg == null then
    image
  else
    image.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            amd64 = hasPlatform "x86_64-linux" pkgs-x86_64-linux;
            arm64 = hasPlatform "aarch64-linux" pkgs-aarch64-linux;
            arm = hasPlatform "armv7l-linux" pkgs-armv7l-linux;
          };
      }
    )
) images
