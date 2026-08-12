{pkgs, ...}: {
  home.packages = [
    pkgs.unstable.jujutsu
  ];
  xdg.configFile = {
    "jj/config.toml".source = ./jj/config.toml;
  };
}
