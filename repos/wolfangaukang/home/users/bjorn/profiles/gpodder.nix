{
  pkgs,
  config,
  ...
}:

{
  home = {
    packages = [ pkgs.gpodder ];
    sessionVariables.GPODDER_HOME = "${config.xdg.configHome}/gPodder";
  };
}
