{ config, lib, pkgs, ... }:
let neuronSrc = builtins.fetchTarball "https://github.com/srid/neuron/archive/master.tar.gz";
    neuronPkg = import neuronSrc {};
in {

  home.packages = with pkgs; [ neuronPkg ];

  systemd.user.services.neuron =
    let notesDir = "${config.home.homeDirectory}/zettelkasten";
    in {
      Unit.Description = "Neuron zettelkasten service";
      Install.WantedBy = [ "graphical-session.target" ];
      Service = {
        ExecStart =
          "${neuronPkg}/bin/neuron -d ${notesDir} rib -ws localhost:8081";
      };
    };
}
