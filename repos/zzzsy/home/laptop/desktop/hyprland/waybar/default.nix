{
  programs.waybar = {
    enable = true;
    style = builtins.readFile ./style.css;
    settings = builtins.fromJSON (builtins.readFile ./config.jsonc);
  };
}
