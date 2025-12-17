{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.my.home.ssh;
in {
  options.my.home.ssh = {
    enable = (mkEnableOption "ssh configuration") // {default = true;};
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks = let
        addGPGAgentForwarding = hostConf:
          {
            remoteForwards = [
              {
                # shhhh this is a path but it works
                bind.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
                host.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
              }
            ];
          }
          // hostConf;
      in {
        boreal = addGPGAgentForwarding {hostname = "boreal.alarsyo.net";};
        hades = addGPGAgentForwarding {hostname = "hades.alarsyo.net";};
        thanatos = addGPGAgentForwarding {hostname = "thanatos.alarsyo.net";};
        pi = addGPGAgentForwarding {
          hostname = "pi.alarsyo.net";
          user = "pi";
        };

        "thanatos.lrde.epita.fr" =
          lib.hm.dag.entryBefore ["*.lrde.epita.fr"]
          (addGPGAgentForwarding {
            user = "alarsyo";
          });

        "*.lrde.epita.fr" = {
          user = "amartin";
        };

        lrde-proxyjump = {
          host = "*.lrde.epita.fr !ssh.lrde.epita.fr";
          proxyJump = "ssh.lrde.epita.fr";
        };
      };

      includes = ["prologin_config"];
    };
  };
}
