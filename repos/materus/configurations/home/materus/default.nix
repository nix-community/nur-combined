{ config, pkgs, lib, ... }:
{

  home.username =  "materus";
  home.packages = [];

  programs.git.signing.key = lib.mkDefault "28D140BCA60B4FD1";
  programs.git.userEmail = lib.mkDefault "materus@podkos.pl";
  programs.git.userName = lib.mkDefault "materus";
}
