{
  pkgs,
  config,
  lib,
  ...
}:

{
  options.services.dunst.enable = lib.mkEnableOption "dunst";

  config = lib.mkIf config.services.dunst.enable {
    # dunst configuration is now managed by workspaced templates
    # See: config/.config/dunst/dunstrc.tmpl

    systemd.user.services.dunst = {
      wantedBy = [ "graphical-session.target" ];
      enable = true;
      restartIfChanged = true;
      path = [ pkgs.dunst ];
      script = ''
        dunst -config ~/.config/dunst/dunstrc
      '';
    };
  };
}
