{pkgs, config, ...}:
let
  our_cudatoolkit = pkgs.cudatoolkit;
in
{
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidia_x11_legacy470;
    # nvidiaPersistenced = true;
  };

  hardware.opengl.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = [
    our_cudatoolkit
    our_cudatoolkit.lib
  ];

  environment.variables = {
    # CUDA_PATH = "${our_cudatoolkit}";
    # CUDA_HOME = "${our_cudatoolkit}";
    # CUDA_VERSION = our_cudatoolkit.version;
    # EXTRA_LDFLAGS="-L/lib -L${config.hardware.nvidia.package}/lib";
    # EXTRA_CCFLAGS="-I/usr/include";
  };
}
