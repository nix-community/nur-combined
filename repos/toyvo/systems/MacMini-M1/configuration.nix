{
  openclaw-pr,
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
    ../../modules/os/gui.nix
    ../../modules/os/dev.nix
    ../../modules/os/podman.nix
    ../../modules/os/users/toyvo.nix
    ../../modules/darwin/defaults.nix
    ../../modules/darwin/podman.nix
    ../../modules/darwin/ollama.nix
    inputs.home-manager.darwinModules.default
    inputs.mac-app-util.darwinModules.default
    inputs.nh.nixDarwinModules.prebuiltin
    inputs.nix-index-database.darwinModules.nix-index
    inputs.nur.modules.darwin.default
    inputs.sops-nix.darwinModules.sops
  ];
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.toyvo.enable = true;
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
    sharedModules = [
      ./home.nix
    ];
  };
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    port = homelab.MacMini-M1.services.ollama.port;
  };
  environment.systemPackages = [ openclaw-pr.legacyPackages.${system}.openclaw ];
}
