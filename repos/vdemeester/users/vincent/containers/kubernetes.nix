{ pkgs, ... }:

{
  home.packages = with pkgs; [
    #cri-tools
    kail
    kubectl
    kustomize
    kubectx
    my.ko
    my.krew
    my.kss
  ];
}
