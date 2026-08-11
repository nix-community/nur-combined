{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
    podman
    distrobox # Run Docker-oriented development environments without nested VMs.
    act # Run GitHub Actions workflows locally.
  ];

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
  };
}
