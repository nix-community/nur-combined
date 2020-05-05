{ pkgs, ... }:

{
  home.file = {
    ".config/ranger/rc.conf".source = ./rc.conf;
    ".config/ranger/colorschemes/default-gruvbox.py".source =
      ./default-gruvbox.py;
  };

  home.packages = with pkgs; [ ranger ];
}
