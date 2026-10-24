{ inputs, outputs }:
{
  host,
  extraModules ? [ ],
  specialArgs ? { },
}:
let
  lib = inputs.nixpkgs.lib;
  hostUtils = import ./hostUtils.nix { inherit lib; };

  inherit (host)
    path
    device
    users
    hostConfig
    ;
  darwinModules = hostUtils.mkModuleTree (inputs.self + /darwin);
  rawNixosModules = hostUtils.mkModuleTree (inputs.self + /nixos);
  nixosModules =
    rawNixosModules
    // lib.filterAttrs (name: _: !(builtins.hasAttr name rawNixosModules)) (
      rawNixosModules.modules or { }
    );
  homeUsersRoot = inputs.self + "/home/users";

  hmModuleFor =
    user: mode:
    hostUtils.mkHmModulePath {
      inherit homeUsersRoot user;
      backend = "darwin";
      hmModuleMode = mode;
    };

  # Canonical hostname: lowercase + dash-separated
  hostId =
    let
      rawName = device.hostname;
    in
    lib.strings.toLower (lib.replaceStrings [ " " "_" "." ] [ "-" "-" "-" ] rawName);

  # UI-facing computer name: CamelCase derived from the hostname
  computerName =
    let
      parts = lib.filter (p: p != "") (lib.strings.splitString "-" hostId);
      cap =
        p:
        let
          lower = lib.strings.toLower p;
          len = builtins.stringLength lower;
        in
        if len <= 1 then
          lib.strings.toUpper lower
        else
          (lib.strings.toUpper (builtins.substring 0 1 lower)) + (builtins.substring 1 (len - 1) lower);
    in
    lib.concatStringsSep "" (map cap parts);

  baseModule =
    { lib, ... }:
    {
      imports = [
        ./nixpkgs.nix
        (inputs.self + /nixos/modules/device-options.nix)
        darwinModules.common.default
      ];

      inherit device;
      nixpkgs.hostPlatform = lib.mkDefault device.system;

      networking = {
        computerName = lib.mkDefault computerName;
        hostName = lib.mkDefault hostId;
      };

      system.stateVersion = lib.mkDefault device.stateVersion;

      users.users = lib.mkMerge (
        map (u: {
          ${u.name}.home = lib.mkDefault "/Users/${u.name}";
        }) users
      );

      home-manager = {
        backupFileExtension = "bak";
        useGlobalPkgs = true;
        extraSpecialArgs = {
          inherit inputs outputs;
          flakeRoot = inputs.self;
          inherit hostConfig;
        };
        users = lib.mkMerge (
          map (u: {
            ${u.name} = lib.mkDefault (import (hmModuleFor u.name u.homeManager.module));
          }) (lib.filter (u: u.homeManager.enable) users)
        );
      };
    };

  modules = [
    baseModule
    path
  ]
  ++ extraModules;
in
inputs.nix-darwin.lib.darwinSystem {
  inherit modules;
  specialArgs = {
    inherit
      inputs
      outputs
      darwinModules
      homeUsersRoot
      ;
    flakeRoot = inputs.self;
    darwinRoot = inputs.self + /darwin;
    homeRoot = inputs.self + /home;
    inherit hostConfig;
    inherit nixosModules;
  }
  // specialArgs;
}
