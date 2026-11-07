{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    docker-credential-helpers # Provides docker-credential-secretservice so `docker login` stores tokens in KWallet.
    podman
    distrobox # Run Docker-oriented development environments without nested VMs.
    act # Run GitHub Actions workflows locally.
  ];

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
  };
}
