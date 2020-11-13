{ config, lib, pkgs, ... }: {

  home.packages = with pkgs; [ neuron-notes ];

  systemd.user.services.neuron =
    let notesDir = "${config.home.homeDirectory}/zettelkasten";
    in {
      Unit.Description = "Neuron zettelkasten service";
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart =
          "${pkgs.neuron-notes}/bin/neuron -d ${notesDir} rib -ws localhost:8081";
      };
    };
}
