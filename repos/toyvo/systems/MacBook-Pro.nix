{ pkgs, stablePkgs, ... }:
{
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
