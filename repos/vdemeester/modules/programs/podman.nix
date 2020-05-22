{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.podman;
in
{
  options = {
    programs.podman = {
      enable = mkOption {
        default = false;
        description = "Enable podman profile";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    # FIXME(vdemeester) package podman and conmon in nixpkgs
    home.packages = with pkgs; [ slirp4netns podman buildah ];
    xdg.configFile."containers/libpod.conf".text = ''
      image_default_transport = "docker://"
      runtime_path = ["/run/current-system/sw/bin/runc"]
      conmon_path = ["/run/current-system/sw/bin/conmon"]
      cni_plugin_dir = ["${pkgs.cni-plugins}/bin/"]
      cgroup_manager = "systemd"
      cni_config_dir = "/etc/cni/net.d/"
      cni_default_network = "podman"
      # pause
      pause_image = "k8s.gcr.io/pause:3.1"
      pause_command = "/pause"
    '';

    xdg.configFile."containers/registries.conf".text = ''
      [registries.search]
      registries = ['docker.io', 'registry.fedoraproject.org', 'quay.io', 'registry.access.redhat.com', 'registry.centos.org']
      [registries.insecure]
      registries = ['massimo.local:5000', '192.168.12.0/16']
    '';

    xdg.configFile."containers/policy.json".text = ''
      {
        "default": [
          { "type": "insecureAcceptAnything" }
        ]
      }
    '';
  };
}
