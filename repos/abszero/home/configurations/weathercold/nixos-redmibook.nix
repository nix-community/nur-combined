let
  inherit (builtins) readDir warn;

  mainModule = {
    abszero = {
      profiles.hyprland.enable = true;
      themes = {
        base = {
          fastfetch.enable = true;
          # firefox.verticalTabs = true;
          hyprland.dynamicCursors.enable = true;
          nushell.enable = true;
        };
        catppuccin = {
          cursors.enable = true;
          fcitx5.enable = true;
          foot.enable = true;
          gtk.enable = true;
          hyprland.enable = true;
          hyprpaper.nixosLogo = true;
        };
      };
    };

    catppuccin = {
      accent = "pink";
      gtk.icon.enable = true;
    };
  };
in

{
  imports = [ ../_options.nix ];

  homeConfigurations."weathercold@nixos-redmibook" = {
    system = "x86_64-linux";
    modules = [
      # inputs.bocchi-cursors.homeModules.bocchi-cursors-shadowBlack
      (
        if (readDir ./. ? "_base.nix") then
          ./_base.nix
        else
          warn "_base.nix is hidden, configuration is incomplete" { }
      )
      mainModule
    ];
  };
}
