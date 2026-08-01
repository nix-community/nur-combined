{ inputs, outputs }:
{
  name,
  path,
  extraModules ? [ ],
  specialArgs ? { },
}:
let
  lib = inputs.nixpkgs.lib;
  hostUtils = import ./hostUtils.nix { inherit lib; };
  nixpkgsConfig = import ./nixpkgsConfig.nix { inherit lib; };

  loadedDeviceConfig = hostUtils.loadDeviceConfig path;
  deviceConfig = loadedDeviceConfig // {
    hostname = loadedDeviceConfig.hostname or name;
  };
  homeUsersRoot = inputs.self + "/home/users";
  outputsForHM = hostUtils.mkOutputsForHM { inherit outputs inputs; };
  rawNixosModules = hostUtils.mkModuleTree (inputs.self + /nixos);
  nixosModules =
    rawNixosModules
    // lib.filterAttrs (name: _: !(builtins.hasAttr name rawNixosModules)) (
      rawNixosModules.modules or { }
    );

  hasHardware = builtins.pathExists (path + "/hardware.nix");
  hasDisko = builtins.pathExists (path + "/disko.nix");

  profileModulePath =
    let
      profile = deviceConfig.profile or null;
      base = ../nixos/profiles;
      directDir = if profile == null then null else base + "/${profile}";
      directFile = if profile == null then null else base + "/${profile}.nix";
    in
    if deviceConfig ? profileModulePath then
      deviceConfig.profileModulePath
    else if profile != null && builtins.pathExists directFile then
      directFile
    else if profile != null && builtins.pathExists directDir then
      directDir
    else
      null;

  userSpecs = map hostUtils.normalizeUser (deviceConfig.users or [ ]);
  hostConfig = {
    device = deviceConfig;
  }
  // hostUtils.mkHostContext deviceConfig;

  hmModuleFor =
    user: mode:
    hostUtils.mkHmModulePath {
      inherit homeUsersRoot user;
      os = "nixos";
      hmModuleMode = mode;
    };

  baseModule =
    { lib, ... }:
    {
      imports = [
        ../nixos/modules/device-options.nix
        ../nixos/common
      ];

      device = deviceConfig;
      nixpkgs.config = nixpkgsConfig;
      nixpkgs.hostPlatform = lib.mkDefault (deviceConfig.system or "x86_64-linux");

      users.users = lib.mkMerge (
        map (u: {
          ${u.name} = {
            isNormalUser = lib.mkDefault true;
            extraGroups = lib.mkDefault u.groups;
            packages = lib.mkDefault u.packages;
          };
        }) userSpecs
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
          inherit inputs;
          outputs = outputsForHM;
          flakeRoot = inputs.self;
          inherit hostConfig;
        };
        users = lib.mkMerge (
          lib.filter (x: x != { }) (
            map (
              u:
              lib.optionalAttrs (u.homeManager.enable or true) {
                ${u.name} = lib.mkDefault (import (hmModuleFor u.name (u.homeManager.module or "auto")));
              }
            ) userSpecs
          )
        );
      };
    };

  modules = [
    baseModule
  ]
  ++ lib.optional hasHardware (path + "/hardware.nix")
  ++ lib.optional hasDisko (path + "/disko.nix")
  ++ lib.optional (profileModulePath != null) profileModulePath
  ++ [ path ]
  ++ extraModules;
in
inputs.nixpkgs.lib.nixosSystem {
  inherit modules;
  specialArgs = {
    inherit inputs;
    outputs = outputsForHM;
    flakeRoot = inputs.self;
    nixosRoot = inputs.self + /nixos;
    homeRoot = inputs.self + /home;
    inherit homeUsersRoot;
    inherit hostConfig;
    inherit nixosModules;
  }
  // specialArgs;
}
