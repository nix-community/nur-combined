{ pkgs, ... }:

{
  imports = [
    ./gcloud.nix
  ];

  home.packages = with pkgs; [
    skopeo
    my.manifest-tool
    # nerdctl
    # act
    oras
    dagger
  ];
}
