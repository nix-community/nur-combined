{ config, lib, ... }:
{
  options.sane.roles.work = with lib; mkOption {
    type = types.bool;
    default = false;
    description = ''
      programs/services used when working for hire.
    '';
  };

  imports = [
    ./tailscale.nix
  ];

  config = lib.mkIf config.sane.roles.work {
    sane.programs.guiApps.suggestedPrograms = [
      "slack"
      "zoom-us"
    ];
  };
}
