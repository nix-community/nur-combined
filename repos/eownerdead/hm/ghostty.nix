{
  lib,
  config,
  ...
}:
{
  options.eownerdead.ghostty = {
    enable = lib.mkEnableOption "Enable ghostty";
  };

  config = lib.mkIf config.eownerdead.ghostty.enable {
    programs.ghostty = {
      enable = true;
      enableBashIntegration = true;
      installBatSyntax = true;
      settings = {
        font-family = "mononoki";
        theme = "light:Adwaita, dark:Adwaita Dark";
        window-theme = "system";
      };
    };
  };
}
