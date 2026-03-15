{
  nixpkgs ? <nixpkgs>,
}:
pkgs: func:
let
  nullIf = x: y: if x then null else y;

  # cross configs -
  # https://github.com/NixOS/nixpkgs/blob/557e6a9892434f7a7247907d3aa12cbdb068649e/lib/systems/examples.nix

  # static config -
  # https://github.com/NixOS/nixpkgs/blob/d5d19eb94ed8350ab4c7d20ee61565b3d8e6b188/pkgs/top-level/stage.nix#L280

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

  pkgs-x86_64-windows = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "x86_64-w64-mingw32";
      libc = "ucrt"; # This distinguishes the mingw (non posix) toolchain
      isStatic = true;
    };
  };

  pkgs-aarch64-windows = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "aarch64-w64-mingw32";
      libc = "ucrt"; # This distinguishes the mingw (non posix) toolchain
      rust.rustcTarget = "aarch64-pc-windows-gnullvm";
      useLLVM = true; # GCC does not support this platform yet
      isStatic = true;
    };
  };

  pkgs-x86_64-darwin = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "x86_64-apple-darwin";
      xcodePlatform = "MacOSX";
      platform = { };
      isStatic = true;
    };
  };

  pkgs-aarch64-darwin = import nixpkgs {
    localSystem = pkgs.stdenv.hostPlatform.system;
    crossSystem = {
      config = "arm64-apple-darwin";
      xcodePlatform = "MacOSX";
      platform = { };
      isStatic = true;
    };
  };
in
builtins.mapAttrs (
  name: package:
  let
    platforms = package.meta.platforms or [ ];
    hasPlatform =
      platform: pkgsTarget:
      if builtins.elem platform platforms then ((func pkgsTarget).${name}) else null;
  in
  if builtins.length platforms == 0 then
    package
  else
    package.overrideAttrs (
      _: prev: {
        passthru =
          (prev.passthru or { })
          // pkgs.lib.filterAttrs (_: v: v != null) {
            x86_64-linux = hasPlatform "x86_64-linux" pkgs-x86_64-linux;
            aarch64-linux = hasPlatform "aarch64-linux" pkgs-aarch64-linux;
            armv7l-linux = hasPlatform "armv7l-linux" pkgs-armv7l-linux;
            armv6l-linux = hasPlatform "armv6l-linux" pkgs-armv6l-linux;
            x86_64-windows = hasPlatform "x86_64-windows" pkgs-x86_64-windows;
            aarch64-windows = hasPlatform "aarch64-windows" pkgs-aarch64-windows;

            # Cross-compilation to darwin doesn't work on linux yet :(
            x86_64-darwin = nullIf pkgs.stdenv.hostPlatform.isLinux (
              hasPlatform "x86_64-darwin" pkgs-x86_64-darwin
            );
            aarch64-darwin = nullIf pkgs.stdenv.hostPlatform.isLinux (
              hasPlatform "aarch64-darwin" pkgs-aarch64-darwin
            );
          };
      }
    )
) (func pkgs)
