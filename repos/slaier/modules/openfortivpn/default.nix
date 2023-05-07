{ ... }: {
  virtualisation.oci-containers.containers.openfortivpn = {
    image = "ghcr.dockerproxy.com/slaier/openfortivpn:latest";
    volumes = [
      "/etc/openfortivpn/config:/etc/openfortivpn/config"
    ];
    extraOptions = [
      "--device=/dev/ppp"
      "--cap-add=NET_ADMIN"
      "--init"
    ];
    ports = [ "1080:1080" ];
    autoStart = false;
  };
}
