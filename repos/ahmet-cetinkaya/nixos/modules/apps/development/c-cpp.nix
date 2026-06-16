{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    clang
    cmake
    ninja
    pkg-config
  ];
}
