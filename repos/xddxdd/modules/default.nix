{
  svpWithNvidia = { config, pkgs, ... }: let
    svp = pkgs.svp.override {
      nvidia_x11 = config.boot.kernelPackages.nvidia_x11;
    };
  in {
    environment.systemPackages = with pkgs; [ svp ];
  };
}
