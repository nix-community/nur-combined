{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    (lib.mkRenamedOptionModule
      [
        "programs"
        "plasma-desktop-lyrics"
      ]
      [
        "programs"
        "lyrica"
      ]
    )
  ];

  options.programs.lyrica = {
    enable = lib.mkEnableOption (lib.mdDoc "Enable Lyrica KDE plugin") // {
      default = true;
    };
  };

  config = lib.mkIf config.programs.lyrica.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.qtwebsockets
      lyrica-plasmoid
    ];
  };
}
