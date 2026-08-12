{ lib, ... }:
{
  imports = [
    ./cloud-savegame.nix
    ./cockpit-extra.nix
    ./telegram_sendmail.nix
    ./nomad.nix
    ./netusage
    ./python-microservices
    ./ts-proxy.nix
    ./phpelo.nix
  ];

  virtualisation.oci-containers.backend = lib.mkDefault "podman";
}
