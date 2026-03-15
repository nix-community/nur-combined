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

  pkgs-x86_64-linux = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "x86_64-unknown-linux-musl";
      isStatic = true;
    };
  };

  pkgs-aarch64-linux = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "aarch64-unknown-linux-musl";
      isStatic = true;
    };
  };

  pkgs-armv7l-linux = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "armv7l-unknown-linux-musleabihf";
      isStatic = true;
    };
  };

  pkgs-armv6l-linux = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "armv6l-unknown-linux-musleabihf";
      isStatic = true;
    };
  };
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
            x86_64-linux = hasPlatform "x86_64-linux" pkgs-x86_64-linux;
            aarch64-linux = hasPlatform "aarch64-linux" pkgs-aarch64-linux;
            armv7l-linux = hasPlatform "armv7l-linux" pkgs-armv7l-linux;
            armv6l-linux = hasPlatform "armv6l-linux" pkgs-armv6l-linux;
          };
      }
    )
) (func pkgs)
