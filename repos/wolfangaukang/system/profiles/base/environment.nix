{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
      git vim p7zip
  ];
}
