{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-nixos-25-05.url = "github:NixOS/nixpkgs/nixos-25.05";
    ieda.url = "github:srcres258/iEDA/own";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-nixos-unstable,
    nixpkgs-nixos-25-05,
    ieda,
  }: let
    lib = nixpkgs.lib;
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;

    # Every channel the package set is expected to evaluate on. They are locked
    # in flake.lock, so `nix build .#channels.<name>.<attr>` is reproducible
    # without NIX_PATH or `--override-input`.
    channelInputs = {
      nixpkgs-unstable = nixpkgs;
      nixos-unstable = nixpkgs-nixos-unstable;
      # Branch `nixos-25.05`; the attribute cannot contain a dot.
      nixos-25-05 = nixpkgs-nixos-25-05;
    };

    iedaPackage = system: let
      packages = ieda.packages.${system} or null;
    in
      if packages != null && packages ? default
      then packages.default
      else null;

    # iEDA is a flake of its own; passing it down keeps `default.nix` from
    # resolving it with impure `builtins.getFlake` during evaluation.
    mkPkgs = channel: system:
      import channel {
        inherit system;
        config.allowBroken = true;
        config.allowUnfree = true;
      };

    packageArgs = channel: system: let
      iedaArgs = lib.optionalAttrs (iedaPackage system != null) {
        ieda = iedaPackage system;
      };
    in
      iedaArgs
      // {
        pkgs = mkPkgs channel system;
      };

    mkChannel = channel: {
      legacyPackages = forAllSystems (system: import ./default.nix (packageArgs channel system));
      packages = forAllSystems (system:
        lib.filterAttrs (_: lib.isDerivation)
        (import ./default.nix (packageArgs channel system)));
      cacheOutputs = forAllSystems (system: (import ./ci.nix (packageArgs channel system)).cacheOutputs);
      nixpkgsVersion = forAllSystems (system: (mkPkgs channel system).lib.version);
    };
  in {
    legacyPackages = forAllSystems (system: import ./default.nix (packageArgs nixpkgs system));
    packages = forAllSystems (system:
      lib.filterAttrs (_: lib.isDerivation) self.legacyPackages.${system});
    nixpkgsVersion = forAllSystems (system: (mkPkgs nixpkgs system).lib.version);
    channels = lib.mapAttrs (_: mkChannel) channelInputs;
  };
}
