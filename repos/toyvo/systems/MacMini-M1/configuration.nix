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
    inputs.nixcfg.modules.os.defaults
    inputs.nixcfg.modules.os.console
    inputs.nixcfg.modules.os.dev
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.users.toyvo
    inputs.nixcfg.modules.darwin.defaults
    inputs.nixcfg.modules.darwin.podman
    inputs.nixcfg.modules.darwin.ollama
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
}
