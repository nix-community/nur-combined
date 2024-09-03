{ config, pkgs, ... }:
{
  services.redis.servers.misskey = {
    enable = true;
    port = 6379;
  };

  systemd.services.podman-misskey = {
    after = [
      "dae.service"
      "nss-lookup.target"
    ];
    requires = [
      "dae.service"
      "nss-lookup.target"
    ];
    # serviceConfig = {
    #   ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
    # };
  };

  virtualisation = {
    oci-containers.backend = "podman";
    oci-containers.containers = {
      misskey = {
        image = "docker.io/misskey/misskey:2024.8.0";
        ports = [ "3000:3000/tcp" ];
        volumes = [
          "/var/lib/misskey/files:/misskey/files"
          "/var/lib/misskey/config:/misskey/.config"
        ];
        extraOptions = [ "--network=host" ];
      };
    };
  };
  systemd.tmpfiles.rules = [
    "C+ /var/lib/misskey/config/default.yml 0744 - - - ${config.age.secrets.misskey.path}"
  ];
}
