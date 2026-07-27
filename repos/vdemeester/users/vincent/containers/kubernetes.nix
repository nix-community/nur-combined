{ config, lib, pkgs, ... }:

with lib;
let
  knd = pkgs.writeScriptBin "knd" ''
    #!${pkgs.stdenv.shell}
    ${pkgs.kubectl}/bin/kubectl get namespaces -o name | ${pkgs.fzf}/bin/fzf --multi | xargs kubectl delete
  '';
in
{
  home.packages = with pkgs; [
    kail
    kubectl
    kustomize
    kind
    ko
    crane
    krew
    kss
    # our own scripts
    knd
    # bekind
    my.chmouzies.kubernetes
    # kubectx
    kubelogin-oidc
  ];
  programs.zsh.initExtra = ''
    alias -g SK="|snazy -s --kail --kail-prefix-format='{pod}'"
  '';
}
