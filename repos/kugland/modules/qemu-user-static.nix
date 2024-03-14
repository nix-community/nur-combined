{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.virtualisation.qemu-user-static;

in {
  options = {
    virtualisation.qemu-user-static = {
      enable = lib.mkEnableOption ''
        qemu-user-static enables the execution of foreign architecture containers with
        QEMU and binfmt_misc (only available on x86_64-linux)
      '';
      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically start the qemu-user-static service on boot";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.qemu-user-static = {
      autoStart = cfg.autoStart;
      extraOptions = ["--rm" "--privileged"];
      cmd = ["--reset" "-p" "yes"];
      image = "docker.io/multiarch/qemu-user-static:latest";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "docker.io/multiarch/qemu-user-static";
        imageDigest = "sha256:fe60359c92e86a43cc87b3d906006245f77bfc0565676b80004cc666e4feb9f0";
        sha256 = "sha256-Fes4LJIDubvplytbujCgmR+eLMstsXSIg4JaHZk3Pko=";
      };
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
