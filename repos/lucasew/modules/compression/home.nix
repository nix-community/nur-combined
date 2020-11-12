{pkgs, ...}: {
  home.packages = with pkgs; [
    p7zip
    unzip
    xarchiver
  ];
}
