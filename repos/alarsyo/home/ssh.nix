{ config, lib, ... }:
let
  cfg = config.my.home.ssh;
in
{
  options.my.home.ssh = with lib; {
    enable = (mkEnableOption "ssh configuration") // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;

      matchBlocks = {
        poseidon = {
          hostname = "poseidon.alarsyo.net";
        };

        "*.lrde.epita.fr" = {
          user = "amartin";
        };

        lrde-proxyjump = {
          host = "*.lrde.epita.fr !ssh.lrde.epita.fr";
          proxyJump = "ssh.lrde.epita.fr";
        };
      };
    };
  };
}
