{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.go
    pkgs.gopls
  ];
}
