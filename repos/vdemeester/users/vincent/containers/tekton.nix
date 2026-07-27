{ pkgs, ... }:

{
  home.packages = with pkgs; [
    tektoncd-cli
    kubernetes-helm
    snazy
    tkn-pac
    tkn-local
    rekor-cli
    cosign
    python312Packages.pyaml
  ];
}
