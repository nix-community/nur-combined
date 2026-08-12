{pkgs, ...}:

{
    systemd.user.services.dotfile-hyprland = {
      path = with pkgs; [
        script-directory-wrapper
        custom.colorpipe
        bash
      ];
      script = ''
        mkdir ~/.config/hypr -p
        cat $(sdw d root)/nix/nodes/gui-common/gui-variants/hyprland/hypr/hyprland.conf | colorpipe > ~/.config/hypr/hyprland.conf
      '';
      restartTriggers = [ ./hyprland/hypr/hyprland.conf ];
      wantedBy = [ "default.target" ];
    };

}
