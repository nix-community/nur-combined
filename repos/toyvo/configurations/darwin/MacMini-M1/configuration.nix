{
  ekaPkgs,
  homelab,
  inputs,
  stablePkgs,
  system,
  unstablePkgs,
  ...
}:
{
  imports = [
    inputs.nixcfg.modules.os.nix
    inputs.nixcfg.modules.os.security
    inputs.nixcfg.modules.os.home-manager
    inputs.nixcfg.modules.os.console
    inputs.nixcfg.modules.os.gui
    inputs.nixcfg.modules.os.dev
    inputs.nixcfg.modules.os.podman
    inputs.nixcfg.modules.os.toyvo
    inputs.nixcfg.modules.darwin.system
    inputs.nixcfg.modules.darwin.bash
    inputs.nixcfg.modules.darwin.homebrew
    inputs.nixcfg.modules.darwin.keyboard
    inputs.nixcfg.modules.darwin.terminfo
    inputs.nixcfg.modules.darwin.touchid
    inputs.nixcfg.modules.darwin.podman
    inputs.nixcfg.modules.darwin.ollama
    inputs.nixcfg.modules.darwin.odysseus
    inputs.home-manager.darwinModules.default
    inputs.mac-app-util.darwinModules.default
    inputs.nix-index-database.darwinModules.nix-index
    inputs.nur.modules.darwin.default
    inputs.sops-nix.darwinModules.sops
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
    system.enable = true;
    dev.enable = true;
  };
  nixcfg.users.toyvo.enable = true;
  home-manager = {
    extraSpecialArgs = {
      inherit
        ekaPkgs
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
      extraPythonPackages =
        ps: with ps; [
          hf-transfer
          rembg
          diffusers
        ];
      llamaCpp.enable = true;
      port = homelab.MacMini-M1.services.odysseus.port;
    };
  };
  nix.linux-builder = {
    enable = true;
    package = unstablePkgs.darwin.linux-builder-vz;
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
