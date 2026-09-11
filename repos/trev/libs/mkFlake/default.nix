{
  nixpkgs ? <nixpkgs>,
  systems ? [
    "aarch64-linux"
    "aarch64-darwin"
    "x86_64-linux"
  ],
  overlays ? import ../../overlays {
    inherit nixpkgs;
  },
  schemas ? import ../../schemas {
    inherit nixpkgs;
  },
}:

let
  lib = nixpkgs.lib;
  darwinCross = import ./darwin-cross.nix { inherit lib; };

  # Flake output attributes that are not per-system
  globalAttrs = [
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
  platforms = map lib.systems.elaborate [
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

  nixpkgsOverlays = [
    overlays.packages
    overlays.images
    overlays.libs
    overlays.trev
  ];

  nixpkgsConfig = {
    allowUnfree = true;
    allowDeprecatedx86_64Darwin = "force";
    android_sdk.accept_license = true;
  };

  mkPackages =
    localSystem:
    import nixpkgs {
      inherit localSystem;
      overlays = nixpkgsOverlays;
      config = nixpkgsConfig;
    };

  mkCrossPackages =
    localSystem: crossSystem:
    let
      localPlatform = lib.systems.elaborate localSystem;
      configuredCrossSystem = darwinCross.configureCrossSystem localPlatform crossSystem;
      isLinuxToDarwin = darwinCross.isLinuxToDarwin localPlatform configuredCrossSystem;
    in
    import nixpkgs {
      localSystem = localPlatform;
      crossSystem = configuredCrossSystem;
      overlays = lib.optional isLinuxToDarwin darwinCross.overlay ++ nixpkgsOverlays;
      config = nixpkgsConfig // lib.optionalAttrs isLinuxToDarwin darwinCross.config;
    };

  # fixes the mainProgram attribute for windows packages
  fixWindows =
    package:
    if package == null then
      null
    else if package.stdenv.hostPlatform.isWindows then
      package.overrideAttrs (
        _: prev:
        let
          meta = prev.meta or { };
          mainProgram = meta.mainProgram or prev.pname or prev.name;
        in
        {
          meta = meta // {
            mainProgram = if lib.hasSuffix ".exe" mainProgram then mainProgram else "${mainProgram}.exe";
          };
        }
      )
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

    crosses = map (
      platform:
      let
        packages = mkCrossPackages system platform;
      in
      {
        inherit packages platform;
        flake = f system packages;
      }
    ) platforms;
  in

  builtins.foldl' (
    attrs: key:

    # Set as <attr>.value
    if builtins.elem key globalAttrs then
      attrs
      // {
        ${key} = (attrs.${key} or { }) // flake.${key};
      }

    # Set as <attr>.<system>.value that merges cross-compilation outputs for each system
    else if builtins.elem key crossAttrs then
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
                              let
                                crossPackage = builtins.tryEval cross.flake.${key}.${name};
                                available =
                                  if crossPackage.success then
                                    builtins.tryEval (lib.meta.availableOn cross.platform crossPackage.value)
                                  else
                                    {
                                      success = true;
                                      value = false;
                                    };
                              in
                              if available.success then
                                if available.value then
                                  tryEval (darwinCross.fixPackage cross.packages (fixWindows (fixStatic crossPackage.value)))
                                else
                                  null
                              else
                                builtins.warn "Failed to evaluate availability of ${key}.${name} for ${cross.platform.config}" null;
                          }) crosses
                        )
                      );
                  }
                )
              )
              (
                lib.filterAttrs (
                  name: package:
                  let
                    res = builtins.tryEval package;
                  in
                  if res.success then
                    let
                      available = builtins.tryEval (lib.meta.availableOn packages.stdenv.hostPlatform package);
                    in
                    if available.success then
                      available.value
                    else
                      builtins.warn "Failed to evaluate availability of ${key}.${name} for system ${system}" false
                  else
                    builtins.warn "Failed to evaluate ${key}.${name} for system ${system}" false
                ) flake.${key}
              );
        };
      }

    # Set as <attr>.<system>.value
    else
      attrs
      // {
        ${key} =
          (attrs.${key} or { })
          //
            lib.optionalAttrs
              (!lib.isDerivation flake.${key} || lib.meta.availableOn packages.stdenv.hostPlatform flake.${key})
              {
                ${system} =
                  if key == "checks" then
                    lib.filterAttrs (_: check: lib.meta.availableOn packages.stdenv.hostPlatform check) flake.${key}
                  else
                    flake.${key};
              };
      }
  ) attrs (builtins.attrNames flake)
) systems
