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

  fixPackage =
    package:
    if package == null then
      null
    else
      package.overrideAttrs (
        _: prev:
        (
          if (prev.stdenv.hostPlatform.isStatic or false) && (!builtins.elem "dev" (prev.outputs or [ ])) then
            {
              outputs = (prev.outputs or [ ]) ++ [ "dev" ];
            }
          else
            { }
        )
        // (
          if (prev.meta.mainProgram or null) != null && (prev.stdenv.hostPlatform.isWindows or false) then
            {
              meta = (prev.meta or { }) // {
                mainProgram = "${prev.meta.mainProgram}.exe";
              };
            }
          else
            { }
        )
      );

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
    default = f system (mkPackages system);
    crosspkgs = map (platform: {
      inherit platform;
      packages = mkCrossPackages system platform;
    }) platforms;
  in

  builtins.foldl' (
    attrs: key:
    if builtins.elem key ignoredAttrs then
      # Set as <attr>.value
      attrs
      // {
        ${key} = (attrs.${key} or { }) // default.${key};
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
                          map (crosspkg: {
                            name = crosspkg.platform.config;
                            value =
                              if (nixpkgs.lib.meta.availableOn (nixpkgs.lib.systems.elaborate crosspkg.platform) package) then
                                fixPackage crosspkg.packages.${key}.${name}
                              else
                                null;
                          }) crosspkgs
                        )
                      );
                  }
                )
              )
              (
                nixpkgs.lib.filterAttrs (
                  _: package: nixpkgs.lib.meta.availableOn { inherit system; } package
                ) default.${key}
              );
        };
      }
    else
      # Set as <attr>.<system>.value
      attrs
      // {
        ${key} = (attrs.${key} or { }) // {
          ${system} = default.${key};
        };
      }
  ) attrs (builtins.attrNames default)
) systems
