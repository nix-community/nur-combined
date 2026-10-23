{
  inputs,
  outputs,
  userKeys,
}:
{
  host,
  extraModules ? [ ],
  specialArgs ? { },
}:
let
  lib = inputs.nixpkgs.lib;
  hostUtils = import ./hostUtils.nix { inherit lib; };
  nixpkgsConfig = import ./nixpkgsConfig.nix { inherit lib; };

  inherit (host)
    name
    path
    device
    users
    hostConfig
    ;
  homeUsersRoot = inputs.self + "/home/users";
  rawNixosModules = hostUtils.mkModuleTree (inputs.self + /nixos);
  nixosModules =
    rawNixosModules
    // lib.filterAttrs (name: _: !(builtins.hasAttr name rawNixosModules)) (
      rawNixosModules.modules or { }
    );

  hasHardware = builtins.pathExists (path + "/hardware.nix");
  hasDisko = builtins.pathExists (path + "/disko.nix");

  profileModulePath = import ./profileModule.nix {
    inherit lib name;
    profilesDir = ../nixos/profiles;
    inherit (device) profile;
  };

  hmModuleFor =
    user: mode:
    hostUtils.mkHmModulePath {
      inherit homeUsersRoot user;
      backend = "nixos";
      hmModuleMode = mode;
    };

  baseModule =
    { lib, ... }:
    {
      imports = [
        ../nixos/modules/device-options.nix
        ../nixos/common
      ];

      inherit device;
      nixpkgs.config = nixpkgsConfig;
      nixpkgs.hostPlatform = lib.mkDefault device.system;

      users.users = lib.mkMerge (
        map (u: {
          ${u.name} = {
            isNormalUser = lib.mkDefault true;
            extraGroups = lib.mkDefault u.groups;
            packages = lib.mkDefault u.packages;
          };
        }) users
      );

      home-manager = {
        backupFileExtension = "bak";
        useUserPackages = lib.mkDefault true;
        sharedModules = [
          {
            nixpkgs.config = nixpkgsConfig;
          }
        ];
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
  ]
  ++ lib.optional hasHardware (path + "/hardware.nix")
  ++ lib.optional hasDisko (path + "/disko.nix")
  ++ [
    profileModulePath
    path
  ]
  ++ extraModules;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit modules;
  specialArgs = {
    inherit inputs outputs userKeys;
    flakeRoot = inputs.self;
    nixosRoot = inputs.self + /nixos;
    homeRoot = inputs.self + /home;
    inherit homeUsersRoot;
    inherit hostConfig;
    inherit nixosModules;
  }
  // specialArgs;
}
