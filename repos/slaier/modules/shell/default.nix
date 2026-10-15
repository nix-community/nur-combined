{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    svc-ports
    fix-entities
  ];

  programs.fish.enable = true;
  programs.yazi.enable = true;
  users.users.nixos.shell = pkgs.fish;
}
