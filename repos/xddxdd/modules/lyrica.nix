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
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.lyrica-plasmoid;
      description = "Path to lyrica-plasmoid package";
    };
  };

  config = lib.mkIf config.programs.lyrica.enable {
    environment.systemPackages = with pkgs; [
      kdePackages.qtwebsockets
      config.programs.lyrica.package
    ];
  };
}
