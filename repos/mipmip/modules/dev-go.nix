{ config, lib, pkgs, unstable, ... }:

{

  environment.systemPackages = with pkgs; [
#    go_1_18
    unstable.go
    gox
    goreleaser
  ];
}
