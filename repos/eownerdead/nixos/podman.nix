{
  lib,
  config,
  ...
}:
{
  options.eownerdead.podman = lib.mkEnableOption ''
    Enable podman
  '';

  config = lib.mkIf config.eownerdead.podman {
    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        autoPrune.enable = true;
      };
      oci-containers.backend = "podman";
    };
  };
}
