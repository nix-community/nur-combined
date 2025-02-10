{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkIf
    mkDefault
    getExe
    removePrefix
    ;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.profiles.base;
in

{
  imports = [ ../../../lib/modules/config/abszero.nix ];

  options.abszero.profiles.base.enable = mkExternalEnableOption config "base profile";

  config = mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    home = {
      stateVersion = "24.11";
      preferXdgDirectories = true;
      # NOTE: this doesn't enable pointerCursor by default.
      pointerCursor = {
        gtk.enable = mkDefault true;
        hyprcursor.enable = mkDefault true;
        x11.enable = mkDefault true;
      };
      # Create .profile so that greetd sets session variables before starting
      # the session, since it only sources .profile, not .zprofile nor
      # .bash_profile.
      # NOTE: hm-session-vars.sh makes sure it's only sourced once.
      file.".profile".text = ''
        . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      '';
      # Print store diff using nvd
      activation.diff = config.lib.dag.entryBefore [ "writeBoundary" ] ''
        if [[ -v oldGenPath ]]; then
          ${getExe pkgs.nvd} diff "$oldGenPath" "$newGenPath"
        fi
      '';
    };

    xdg.enable = true;

    programs = {
      home-manager.enable = true;
      zsh = {
        enable = true;
        # Hack since `dotDir` is relative to home
        dotDir = "${removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/zsh";
        autocd = true;
      };
    };
  };
}
