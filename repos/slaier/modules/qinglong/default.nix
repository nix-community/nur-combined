{ lib, pkgs, ... }: {
  virtualisation.oci-containers.containers.qinglong = {
    image = "docker.io/whyour/qinglong:latest";
    imageFile = pkgs.dockerTools.pullImage {
      imageName = "whyour/qinglong";
      imageDigest = "sha256:02e7ad3fd86ed62ae36fae97db36e6d1afb60eae14aff00abc0868ef601ca35d";
      sha256 = "sha256-PGuTgHdXclGLFs2AwNrRNeOwhe2cxRq8AfCqg60R/Oo=";
      os = "linux";
      arch = "arm64";
    };
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
