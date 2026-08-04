{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.eownerdead.emacs;
in
{
  options.eownerdead.emacs.enable = lib.mkEnableOption "Enable emacs";

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        emacs-all-the-icons-fonts
        mononoki
      ];
    };

    programs = {
      emacs = {
        enable = true;
        package = pkgs.eownerdead.emacs;
      };
      bash.bashrcExtra = ''
        [ -n "$EAT_SHELL_INTEGRATION_DIR" ] && \
          source "$EAT_SHELL_INTEGRATION_DIR/bash"
        [[ "''${INSIDE_EMACS%%,*}" = 'ghostel' ]] && \
          source "$EMACS_GHOSTEL_PATH/etc/shell/ghostel.bash"
      '';
    };

    services = {
      emacs = {
        enable = true;
        client.enable = true;
        defaultEditor = true;
      };
    };
  };
}
