{
  nixpkgs ? <nixpkgs>,
  systems ? [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
  ],
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

  mkPackages =
    localSystem:
    import nixpkgs {
      inherit localSystem;
      overlays = [
        overlays.images
        overlays.libs
        overlays.packages
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
  # Merge outputs for each system.
  f: attrs: system:
  let
    flake = f system (mkPackages system);
    crosses = map (platform: {
      platform = nixpkgs.lib.systems.elaborate platform;
      flake = f system (mkCrossPackages system platform);
    }) platforms;
  in

  builtins.foldl' (
    attrs: key:
    if builtins.elem key ignoredAttrs then
      # Set as <attr>.value
      attrs
      // {
        ${key} = (attrs.${key} or { }) // flake.${key};
      }
    else if builtins.elem key crossAttrs then
      # Set as <attr>.<system>.value that merges cross-compilation outputs for each system
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} =
            builtins.mapAttrs
              (
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
                              if (nixpkgs.lib.meta.availableOn cross.platform package) then
                                fixWindows (fixDarwin (fixStatic (cross.flake.${key}.${name})))
                              else
                                null;
                          }) crosses
                        )
                      );
                  }
                )
              )
              (
                nixpkgs.lib.filterAttrs (
                  _: package: nixpkgs.lib.meta.availableOn { inherit system; } package
                ) flake.${key}
              );
        };
      }
    else
      # Set as <attr>.<system>.value
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = flake.${key};
        };
      }
  ) attrs (builtins.attrNames flake)
) systems
