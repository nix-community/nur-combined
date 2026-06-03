{
  inputs,
  system,
  homelab,
  stablePkgs,
  unstablePkgs,
  config,
  ...
}:
{
  imports = [
    inputs.nixcfg.modules.darwin.default
    inputs.home-manager.darwinModules.default
    inputs.mac-app-util.darwinModules.default
    inputs.nh.nixDarwinModules.prebuiltin
    inputs.nix-index-database.darwinModules.nix-index
    inputs.nur.modules.darwin.default
    inputs.sops-nix.darwinModules.sops
    inputs.odysseus.darwinModules.default
  ];
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    darwin.touchid.enable = true;
    darwin.homebrew.enable = true;
    darwin.keyboard.enable = true;
    darwin.bash.enable = true;
    darwin.terminfo.enable = true;
    gui.enable = true;
    console.enable = true;
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
  services = {
    ollama = {
      enable = true;
      host = "0.0.0.0";
      port = homelab.MacMini-M1.services.ollama.port;
      package = unstablePkgs.ollama;
    };
    odysseus = {
      enable = true;
      port = homelab.MacMini-M1.services.odysseus.port;
    };
  };
}
