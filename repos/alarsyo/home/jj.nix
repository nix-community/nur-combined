{pkgs, ...}: {
  home.packages = [
    pkgs.jujutsu
  ];
  xdg.configFile = {
    "jj/config.toml".source = ./jj/config.toml;
  };
}
