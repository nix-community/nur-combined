{
  config,
  pkgs,
  lib,
  ...
}:
# https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/modules/k3s/kata-containers.nix
let
  settingsFormat = pkgs.formats.toml {};
  cfg = config.virtualisation.kata-containers;
  configFile = settingsFormat.generate "configuration.toml" cfg.settings;
in {
  options = {
    virtualisation.kata-containers.settings = lib.mkOption {
      type = settingsFormat.type;
      default = {};
      description = ''
        Settings for kata's configuration.toml
      '';
    };
  };
  config = {
    environment.etc."/etc/kata-containers/configuration.toml".source = configFile;

    systemd.tmpfiles.rules = [
      "L+ /var/lib/kata-containers - - - - ${pkgs.kata-image}/share/kata-containers"
    ];

    virtualisation.docker.daemon.settings.runtimes.kata-runtime.path = "${pkgs.kata-runtime}/bin/kata-runtime";
    virtualisation.podman.extraPackages = [pkgs.kata-runtime];
  };
}
