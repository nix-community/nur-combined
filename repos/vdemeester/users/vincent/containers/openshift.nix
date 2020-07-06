{ pkgs, ... }:

{
  home.file.".local/share/applications/chos4.desktop".source = ./chos4.desktop;
  home.packages = with pkgs; [
    my.crc
    my.oc
    #my.openshift-install
    my.operator-sdk
  ];
}
