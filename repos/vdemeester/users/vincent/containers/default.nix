{ pkgs, ... }:

{
  imports = [
    ./gcloud.nix
    ./kubernetes.nix
    ./openshift.nix
    ./tekton.nix
  ];

  home.packages = with pkgs; [
    skopeo
  ];
}
