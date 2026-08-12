{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf config.programs.ccache.enable {
  nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
}
