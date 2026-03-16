{
  nixpkgs ? <nixpkgs>,
}:
pkgs: func:
let
  # helpers
  nullIf = x: y: if x then null else y;
  try =
    e:
    let
      res = builtins.tryEval e;
    in
    if res.success then res.value else null;

  # get all packages that support the current system
  packages = pkgs.lib.filterAttrs (
    _: package:
    (!pkgs.lib.attrsets.hasAttrByPath [ "meta" "platforms" ] package)
    || (builtins.elem pkgs.stdenv.buildPlatform.system package.meta.platforms)
  ) (func pkgs);

  # pkgs for cross-compilation
  # cross configs -
  # https://github.com/NixOS/nixpkgs/blob/557e6a9892434f7a7247907d3aa12cbdb068649e/lib/systems/examples.nix
  # static config -
  # https://github.com/NixOS/nixpkgs/blob/d5d19eb94ed8350ab4c7d20ee61565b3d8e6b188/pkgs/top-level/stage.nix#L280
  #
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
  pkgs-x86_64-windows = mkCrossPkgs {
    config = "x86_64-w64-mingw32";
    libc = "ucrt"; # This distinguishes the mingw (non posix) toolchain
    isStatic = true;
  };
  pkgs-aarch64-windows = mkCrossPkgs {
    config = "aarch64-w64-mingw32";
    libc = "ucrt"; # This distinguishes the mingw (non posix) toolchain
    rust.rustcTarget = "aarch64-pc-windows-gnullvm";
    useLLVM = true; # GCC does not support this platform yet
    isStatic = true;
  };
  pkgs-x86_64-darwin = mkCrossPkgs {
    config = "x86_64-apple-darwin";
    xcodePlatform = "MacOSX";
    platform = { };
    isStatic = true;
  };
  pkgs-aarch64-darwin = mkCrossPkgs {
    config = "arm64-apple-darwin";
    xcodePlatform = "MacOSX";
    platform = { };
    isStatic = true;
  };

  # tries to create the cross-compiled package
  mkPackage = crossPkgs: name: try ((func crossPkgs).${name});

  # fixes the mainProgram attribute for windows binaries
  fixupPackage =
    package:
    if package == null then
      null
    else if
      package.stdenv.hostPlatform.isWindows
      && pkgs.lib.attrsets.hasAttrByPath [ "meta" "mainProgram" ] package
    then
      package.overrideAttrs (
        _: prev: {
          meta = prev.meta // {
            mainProgram = "${prev.meta.mainProgram}.exe";
          };
        }
      )
    else
      package;
in

builtins.mapAttrs (
  name: package:
  let
    platforms = package.meta.platforms or [ ];
    hasPlatform =
      crossPkgs:
      if builtins.elem crossPkgs.stdenv.hostPlatform.system platforms then
        fixupPackage (mkPackage crossPkgs name)
      else
        null;
  in
  if builtins.length platforms == 0 then
    package
  else
    package.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            x86_64-linux = hasPlatform pkgs-x86_64-linux;
            aarch64-linux = hasPlatform pkgs-aarch64-linux;
            armv7l-linux = hasPlatform pkgs-armv7l-linux;
            armv6l-linux = hasPlatform pkgs-armv6l-linux;
            x86_64-windows = hasPlatform pkgs-x86_64-windows;
            aarch64-windows = hasPlatform pkgs-aarch64-windows;

            # Cross-compilation to darwin doesn't work on linux yet :(
            x86_64-darwin = nullIf pkgs.stdenv.hostPlatform.isLinux (hasPlatform pkgs-x86_64-darwin);
            aarch64-darwin = nullIf pkgs.stdenv.hostPlatform.isLinux (hasPlatform pkgs-aarch64-darwin);
          };
      }
    )
) packages
