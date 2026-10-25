{
  ekaPkgs,
  homelab,
  inputs,
  pkgs,
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
    inputs.nixcfg.modules.darwin.android
    inputs.home-manager.darwinModules.default
    inputs.mac-app-util.darwinModules.default
    inputs.nix-index-database.darwinModules.nix-index
    inputs.nur.modules.darwin.default
    inputs.sops-nix.darwinModules.sops
  ];
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
  nixcfg = {
    nix.enable = true;
    security.enable = true;
    home-manager.enable = true;
    darwin.android.enable = true;
    darwin.touchid.enable = true;
    darwin.homebrew.enable = true;
    darwin.keyboard.enable = true;
    darwin.bash.enable = true;
    darwin.terminfo.enable = true;
    gui.enable = true;
    dev.enable = true;
  };
  nixcfg.users.toyvo.enable = true;
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
    {
      name = "syncthing-app";
    }
  ];
  homebrew.masApps = {
    "Yubico Authenticator" = 1497506650;
    "Wireguard" = 1451685025;
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
