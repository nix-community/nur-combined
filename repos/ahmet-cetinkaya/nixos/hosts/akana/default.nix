{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/boot.nix
    ../../modules/core/locale.nix
    ../../modules/core/network.nix
    ../../modules/core/nix.nix
    ../../modules/core/ssh.nix
    ../../modules/core/docker.nix
    ../../modules/core/dokploy.nix
    ../../modules/core/cloudflared.nix
    ../../modules/core/tailscale.nix
  ];

  networking.hostName = "akana";

  system.stateVersion = "26.05";
}
