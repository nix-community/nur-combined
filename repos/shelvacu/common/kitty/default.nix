{
  config,
  lib,
  pkgs,
  vacuModuleType,
  ...
}:
lib.optionalAttrs (vacuModuleType == "nixos") {
  config = lib.mkIf (config.vacu.isGui && !config.vacu.isMinimal) {
    environment.systemPackages = [ pkgs.kitty ];
    vacu.fontPackages = "nerd-fonts.geist-mono";
    # kitty falls back to $XDG_CONFIG_DIRS when ~/.config/kitty/kitty.conf doesn't exist
    environment.etc."xdg/kitty/kitty.conf".source = ./kitty.conf;
    environment.etc."xdg/kitty/themes/carbonfox.conf".source = ./carbonfox.conf;
  };
}
