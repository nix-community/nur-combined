{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.rio;

  # Fetched during evaluation via builtins.fetchTarball, so no build-time
  # derivation dependency. Hash verified for the referenced commit.
  rioThemeSrc = builtins.fetchTarball {
    url = "https://github.com/catppuccin/rio/archive/6c7e7f9ce7eeb1ae621beadd8f93641f6752c14d.tar.gz";
    sha256 = "1zy3i9z0f1m8djmirjc778ga0hf666g8dy3kk4pn8cdmawb9zp4v";
  };
in
{
  config = lib.mkIf cfg.enable {
    programs.rio.settings = {
      window = {
        width = 1200;
        height = 800;
      };
      shell = {
        program = "${lib.getExe pkgs.nushell}";
        args = [ ];
      };
    }
    // lib.importTOML "${rioThemeSrc}/themes/catppuccin-${config.catppuccin.flavor}.toml";
  };
}
