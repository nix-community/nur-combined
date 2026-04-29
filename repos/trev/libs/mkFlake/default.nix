{
  nixpkgs ? <nixpkgs>,
  systems ? [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
  ],
  lib ? nixpkgs.lib,
}:

let
  # Flake output attributes that are not per-system
  ignoredAttrs = [
    "hydraJobs"
    "libs"
    "nixosConfigurations"
    "nixosModules"
    "overlays"
    "schemas"
    "templates"
  ];

  # Flake output attributes that can be cross-compiled
  crossAttrs = [
    "packages"
    "images"
    "appimages"
  ];

  # https://github.com/NixOS/nixpkgs/blob/master/lib/systems/examples.nix
  platforms = [
    {
      config = "x86_64-unknown-linux-gnu";
    }
    {
      config = "x86_64-unknown-linux-musl";
      isStatic = true;
    }
    {
      config = "aarch64-unknown-linux-gnu";
    }
    {
      config = "aarch64-unknown-linux-musl";
      isStatic = true;
    }
    {
      config = "armv7l-unknown-linux-gnueabihf";
    }
    {
      config = "armv7l-unknown-linux-musleabihf";
      isStatic = true;
    }
    {
      config = "armv6l-unknown-linux-gnueabihf";
    }
    {
      config = "armv6l-unknown-linux-musleabihf";
      isStatic = true;
    }
    {
      config = "x86_64-w64-mingw32";
      libc = "ucrt";
    }
    {
      config = "aarch64-w64-mingw32";
      libc = "ucrt";
      rust.rustcTarget = "aarch64-pc-windows-gnullvm";
      useLLVM = true;
    }
    {
      config = "x86_64-apple-darwin";
      xcodePlatform = "MacOSX";
      platform = { };
    }
    {
      config = "arm64-apple-darwin";
      xcodePlatform = "MacOSX";
      platform = { };
    }
  ];

  overlays = import ../../overlays {
    inherit nixpkgs;
  };

  schemas = import ../../schemas {
    inherit nixpkgs lib;
  };

  mkPackages =
    localSystem:
    import nixpkgs {
      inherit localSystem;
      overlays = [
        overlays.images
        overlays.libs
        overlays.packages
        overlays.python
      ];
      config = {
        allowUnfree = true;
        allowDeprecatedx86_64Darwin = true;
      };
    };

  mkCrossPackages =
    localSystem: crossSystem:
    import nixpkgs {
      inherit localSystem crossSystem;
      overlays = [
        overlays.images
        overlays.libs
        overlays.packages
        overlays.python
      ];
      config = {
        allowUnfree = true;
        allowDeprecatedx86_64Darwin = true;
      };
    };

  # fixes the mainProgram attribute for windows packages
  fixWindows =
    package:
    if package == null then
      null
    else if package.stdenv.hostPlatform.isWindows then
      package.overrideAttrs (
        _: prev: {
          meta = prev.meta // {
            mainProgram = "${prev.meta.mainProgram or prev.pname or prev.name}.exe";
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
    else if package.stdenv.hostPlatform.isDarwin && package.stdenv.buildPlatform.isLinux then
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
          postFixup = prev.postFixup or "" + ''
            # HACK: Otherwise the result will have the entire buildInputs closure
            # injected by the pkgsStatic stdenv
            # <https://github.com/NixOS/nixpkgs/issues/83667>
            rm -f $out/nix-support/propagated-build-inputs
          '';
        }
      )
    else
      package;

  tryEval =
    package:
    let
      res = builtins.tryEval package;
    in
    if res.success then res.value else null;

  # Applies a merge operation across systems.
  eachSystemOp =
    op: systems: f:
    builtins.foldl' (op f) { } (
      if !builtins ? currentSystem || builtins.elem builtins.currentSystem systems then
        systems
      else
        # Add the current system if the --impure flag is used.
        systems ++ [ builtins.currentSystem ]
    );
in

# Builds a map from <attr>.value to <attr>.<system>.value for each system.
eachSystemOp (
  f: attrs: system:

  let
    packages = mkPackages system;
    flake = {
      inherit schemas;
      nixpkgs = packages;
    }
    // (f system packages);

    crosses = map (platform: {
      platform = lib.systems.elaborate platform;
      flake = f system (mkCrossPackages system platform);
    }) platforms;
  in

  builtins.foldl' (
    attrs: key:

    # Set as <attr>.value
    if builtins.elem key ignoredAttrs then
      attrs
      // {
        ${key} = (attrs.${key} or { }) // flake.${key};
      }

    # Set as <attr>.<system>.value that merges cross-compilation outputs for each system
    else if builtins.elem key crossAttrs then
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = builtins.mapAttrs (
            name: package:
            package.overrideAttrs (
              _: prev: {
                passthru =
                  (prev.passthru or { })
                  // builtins.listToAttrs (
                    builtins.filter (pv: pv.value != null) (
                      map (cross: {
                        name = cross.platform.config;
                        value =
                          if (lib.meta.availableOn cross.platform package) then
                            tryEval (fixWindows (fixDarwin (fixStatic (cross.flake.${key}.${name}))))
                          else
                            null;
                      }) crosses
                    )
                  );
              }
            )
          ) (lib.filterAttrs (_: package: lib.meta.availableOn { inherit system; } package) flake.${key});
        };
      }

    # Set as <attr>.<system>.value
    else
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = flake.${key};
        };
      }
  ) attrs (builtins.attrNames flake)
) systems
