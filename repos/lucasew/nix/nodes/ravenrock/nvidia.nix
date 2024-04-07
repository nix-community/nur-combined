{ pkgs, config, ... }:
let
  our_cudatoolkit = pkgs.cudatoolkit;
in
{
  nix = {
    settings = {
      substituters = [ "https://cuda-maintainers.cachix.org" ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };
  };
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidia_x11_legacy470;
    # nvidiaPersistenced = true;
  };

  virtualisation.docker.enableNvidia = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = [
    # our_cudatoolkit
    # our_cudatoolkit.lib
  ];
}
