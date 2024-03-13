{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.virtualisation.qemu-user-static;

  defaultImageParams = {
    imageName = "docker.io/multiarch/qemu-user-static";
    finalImageTag = "7.2.0-1";
    imageDigest = "sha256:fe60359c92e86a43cc87b3d906006245f77bfc0565676b80004cc666e4feb9f0";
    sha256 = "sha256-eVBXjH7ltxM1Ojhub4gjqKYe64/2ySuEpCqBm3w7wfY=";
    os = "linux";
    arch = "x86_64";
  };
in {
  options = {
    virtualisation.qemu-user-static = {
      enable = lib.mkEnableOption "qemu-user-static enables the execution of foreign architecture containers with QEMU and binfmt_misc (only available on x86_64-linux)";
      image = lib.mkOption {
        type = lib.types.package;
        default = pkgs.dockerTools.pullImage defaultImageParams;
        description = ''
          The image to use for qemu-user-static.
        '';
        example = ''
          pkgs.dockerTools.pullImage {
            imageName = "docker.io/multiarch/qemu-user-static";
            finalImageTag = "7.2.0-1";
            imageDigest = "sha256:fe60359c92e86a43cc87b3d906006245f77bfc0565676b80004cc666e4feb9f0";
            sha256 = "sha256-eVBXjH7ltxM1Ojhub4gjqKYe64/2ySuEpCqBm3w7wfY=";
            os = "linux";
            arch = "x86_64";
          }
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.qemu-user-static = {
      autoStart = true;
      extraOptions = ["--rm" "--privileged"];
      cmd = ["--reset" "-p" "yes"];
      image = cfg.image.destNameTag;
      imageFile = cfg.image;
    };
    systemd.services.podman-qemu-user-static.serviceConfig = {
      Type = lib.mkForce "oneshot";
      Restart = lib.mkForce "no";
    };
    assertions = [
      {
        assertion = with config.nixpkgs.hostPlatform; (isx86_64 && isLinux);
        message = "qemu-user-static is only available on x86_64-linux";
      }
    ];
  };
}
