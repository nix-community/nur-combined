{ pkgs, ... }:
{
  home.packages = with pkgs; [
    colloid-kde
    qtstyleplugin-kvantum
  ];
}
