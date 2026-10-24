{
  pkgs,
  ...
}:

{
  imports = [
    ../.
    ./graphical.nix
    ../config/shell/bash.nix
  ];

  home = {
    username = "iamanaws";
    homeDirectory = "/home/iamanaws";
  };

  home.packages = with pkgs; [ ];
}
