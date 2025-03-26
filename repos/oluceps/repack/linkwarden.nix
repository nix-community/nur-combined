{
  reIf,
  ...
}:
reIf {
  virtualisation.oci-containers.containers.linkwarden = {

    image = "ghcr.io/linkwarden/linkwarden:latest";
    extraOptions = [ "--network=host" ];
    environment = {

    };
    ports = [
      "[::1]:3004:3000"
    ];
    workdir = "/var/lib/linkwarden";
  };
}
