{ pkgs, ... }:

{

  environment.systemPackages = [
    # (pkgs.llama-cpp.override {
    #   rocmSupport = true;
    #   rocmPackages = pkgs.rocmPackages;
    #   rocmGpuTargets = [
    #     # "gfx900"
    #     # "gfx906"
    #     # "gfx908"
    #     # "gfx90a"
    #     # "gfx942"
    #     # "gfx1010"
    #     # "gfx1030"
    #     "gfx1100"
    #     "gfx1101"
    #     "gfx1102"
    #     # "gfx1150"
    #     # "gfx1151"
    #     # "gfx1200"
    #     # "gfx1201"
    #   ];
    # })
    # pkgs.llama-cpp-rocm
    # pkgs.llama-cpp
  ];

}
