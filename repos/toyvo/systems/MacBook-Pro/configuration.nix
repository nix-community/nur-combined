{
  pkgs,
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
  profiles = {
    defaults.enable = true;
    dev.enable = true;
  };
  userPresets.toyvo.enable = true;
  environment.systemPackages = with pkgs; [
    # openscad
    # ollama
    stablePkgs.prismlauncher
    packwiz
    vlc-bin
  ];
  homebrew.casks = [
    {
      name = "freecad";
    }
    {
      name = "blender";
    }
    {
      name = "discord";
    }
    {
      name = "steam";
    }
    {
      name = "obs";
    }
    {
      name = "prusaslicer";
    }
    {
      name = "whisky";
    }
    {
      name = "ollama-app";
    }
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
  };
}
