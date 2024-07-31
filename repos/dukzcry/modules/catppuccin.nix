{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.programs.catppuccin;
  catppuccin = pkgs.nur.repos.dukzcry.catppuccin.override { variant = cfg.variant; };
  capitalize = s: toUpper (substring 0 1 s) + substring 1 (-1) s;
  capitalizedVariant = capitalize cfg.variant;
  capitalizedAccent = capitalize cfg.accent;
in {
  options.programs.catppuccin = {
    enable = mkEnableOption "catppuccin support";
    accent = mkOption {
      type = types.str;
    };
    variant = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    environment.etc."sway/config.d/catppuccin.conf".source = "${catppuccin}/i3/catppuccin-${cfg.variant}";

    environment.etc."mako.conf".text = mkBefore (builtins.readFile "${catppuccin}/mako/${cfg.variant}");

    environment.etc."xdg/foot/foot.ini".text = ''
      include=${catppuccin}/foot/catppuccin-${cfg.variant}.ini
    '';

    environment.etc."swaylock.conf".text = builtins.readFile "${catppuccin}/swaylock/${cfg.variant}.conf";

    theme = {
      enable = true;
      platform = "kvantum";
      theme = "Catppuccin-${capitalizedVariant}-Standard-${capitalizedAccent}-Light";
      kvantumTheme = "Catppuccin-${capitalizedVariant}-${capitalizedAccent}";
      iconTheme = "Papirus";
      cursorTheme = "Catppuccin-${capitalizedVariant}-${capitalizedAccent}-Cursors";
      extraPackages = with pkgs; [
        (catppuccin-gtk.override { accents = [ cfg.accent ]; variant = cfg.variant; })
        (catppuccin-kvantum.override { accent = capitalizedAccent; variant = capitalizedVariant; })
        (catppuccin-papirus-folders.override { accent = cfg.accent; flavor = cfg.variant; })
        catppuccin-cursors."${cfg.variant}${capitalizedAccent}"
      ];
    };
  };
}
