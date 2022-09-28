{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    kubernetes-helm
    helmfile
    kustomize
  ];
}
