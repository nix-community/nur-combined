{ lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.qinglong = {
    image = "ghcr.io/whyour/qinglong:latest";
    imageFile = pkgs.dockerTools.pullImage (import ./source.nix);
    volumes = [
      "/var/lib/qinglong:/ql/data"
    ];
    ports = [ "5700:5700" ];
    extraOptions = [
      "--init"
    ];
  };
  system.activationScripts.qinglong = lib.stringAfter [ "var" ] ''
    mkdir -p /var/lib/qinglong
  '';
}
