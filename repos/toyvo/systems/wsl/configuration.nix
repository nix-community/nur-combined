{
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  ...
}:
{
  imports = [
    ../../modules/os/defaults.nix
    ../../modules/os/console.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/nixos/defaults.nix
    inputs.nixos-wsl.nixosModules.wsl
    inputs.arion.nixosModules.arion
    inputs.catppuccin.nixosModules.catppuccin
    inputs.dioxus_monorepo.nixosModules.discord_bot
    inputs.disko.nixosModules.disko
    inputs.home-manager.nixosModules.default
    inputs.nh.nixosModules.default
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nixpkgs-unstable.nixosModules.notDetected
    inputs.nur.modules.nixos.default
    inputs.sops-nix.nixosModules.sops
  ];
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        system
        homelab
        stablePkgs
        unstablePkgs
        ;
    };
    sharedModules = [ ./home.nix ];
  };
  networking.hostName = "wsl";
  profiles = {
    defaults.enable = true;
  };
  userPresets.toyvo.enable = true;
  wsl.enable = true;
  wsl.defaultUser = "toyvo";
}
