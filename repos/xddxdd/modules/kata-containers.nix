{
  config,
  pkgs,
  lib,
  ...
}:
# https://github.com/TUM-DSE/doctor-cluster-config/blob/0c40be8dd86282122f8f04df738c409ef5e3da1c/modules/k3s/kata-containers.nix
let
  settingsFormat = pkgs.formats.toml { };
  cfg = config.virtualisation.kata-containers;
  configFile = settingsFormat.generate "configuration.toml" cfg.settings;
in
{
  options = {
    virtualisation.kata-containers = {
      imagePackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kata-image;
        description = "Path to kata-image package";
      };
      runtimePackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kata-runtime;
        description = "Path to kata-runtime package";
      };
      settings = lib.mkOption {
        inherit (settingsFormat) type;
        default = { };
        description = ''
          Settings for kata's configuration.toml
        '';
      };
    };
  };
  config = {
    environment.etc."/etc/kata-containers/configuration.toml".source = configFile;

    systemd.tmpfiles.rules = [
      "L+ /var/lib/kata-containers - - - - ${config.virtualisation.kata-containers.imagePackage}/share/kata-containers"
    ];

    virtualisation.docker.daemon.settings.runtimes.kata-runtime.path = "${config.virtualisation.kata-containers.runtimePackage}/bin/kata-runtime";
    virtualisation.podman.extraPackages = [ config.virtualisation.kata-containers.runtimePackage ];
  };
}
