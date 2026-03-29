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

  # get all packages that support the current system
  packages = pkgs.lib.filterAttrs (
    _: package:
    (!pkgs.lib.attrsets.hasAttrByPath [ "meta" "platforms" ] package)
    || (builtins.elem pkgs.stdenv.buildPlatform.system package.meta.platforms)
  ) (func pkgs);

  # create cross-compilation pkgs
  mkCrossPkgs =
    crossSystem:
    (import nixpkgs {
      localSystem = pkgs.stdenv.buildPlatform.system;
      inherit crossSystem;
      inherit (pkgs) config overlays;
    });

  # pkgs for cross-compilation
  # cross configs -
  # https://github.com/NixOS/nixpkgs/blob/557e6a9892434f7a7247907d3aa12cbdb068649e/lib/systems/examples.nix
  # static config -
  # https://github.com/NixOS/nixpkgs/blob/d5d19eb94ed8350ab4c7d20ee61565b3d8e6b188/pkgs/top-level/stage.nix#L280

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
    libc = "ucrt";
  };
  pkgs-x86_64-darwin = mkCrossPkgs {
    config = "x86_64-apple-darwin";
    xcodePlatform = "MacOSX";
    platform = { };
  };
  pkgs-aarch64-darwin = mkCrossPkgs {
    config = "arm64-apple-darwin";
    xcodePlatform = "MacOSX";
    platform = { };
  };

  # fixes the mainProgram attribute for windows packages
  fixWindows =
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

  # cross-compilation from linux to darwin doesn't work yet
  # https://nixos.org/manual/nixpkgs/stable/#sec-platform-breakdown
  fixDarwin =
    package:
    if package == null then
      null
    else if package.stdenv.hostPlatform.isDarwin && pkgs.stdenv.hostPlatform.isLinux then
      null
    else
      package;

  # add dev otherwise the result will have the entire buildInputs closure
  # https://github.com/NixOS/nixpkgs/issues/83667
  fixStatic =
    package:
    if package == null then
      null
    else if package.stdenv.hostPlatform.isStatic then
      package.overrideAttrs (
        _: prev: {
          outputs =
            if prev ? outputs then
              if builtins.elem "dev" prev.outputs then prev.outputs else prev.outputs ++ [ "dev" ]
            else
              [
                "out"
                "dev"
              ];
        }
      )
    else
      package;

  # make sure the package is available on the current platform
  hasPlatform =
    package:
    if package == null then
      null
    else if pkgs.lib.meta.availableOn package.stdenv.hostPlatform package then
      package
    else
      null;

  # creates a package for a given pkgs set and fixes it up
  mkPackage = name: pkgs: fixWindows (fixDarwin (fixStatic (hasPlatform (try (func pkgs).${name}))));
in

builtins.mapAttrs (
  name: package:
  package.overrideAttrs (
    _: prev: {
      passthru =
        (prev.passthru or { })
        // pkgs.lib.filterAttrs (_: v: v != null) {
          x86_64-linux = mkPackage name pkgs-x86_64-linux;
          aarch64-linux = mkPackage name pkgs-aarch64-linux;
          armv7l-linux = mkPackage name pkgs-armv7l-linux;
          armv6l-linux = mkPackage name pkgs-armv6l-linux;
          x86_64-windows = mkPackage name pkgs-x86_64-windows;
          x86_64-darwin = mkPackage name pkgs-x86_64-darwin;
          aarch64-darwin = mkPackage name pkgs-aarch64-darwin;
        };
    }
  )
) packages
