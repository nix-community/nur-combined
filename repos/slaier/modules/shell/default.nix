{ pkgs, ... }:
{
  programs.fish.enable = true;
  users.users.nixos.shell = pkgs.fish;
}
