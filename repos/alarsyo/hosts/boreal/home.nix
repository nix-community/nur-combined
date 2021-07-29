{ config, pkgs, ... }:
{
  home-manager.users.alarsyo = {
    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3bar.temperature.chip = "k10temp-pci-*";
    my.home.x.i3bar.temperature.inputs =  [ "Tccd1" ];
    my.home.emacs.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;

    home.packages = with pkgs; [
        blender

        # some websites only work there :(
        chromium

        # dev
        rustup

        unstable.beancount
        unstable.fava

        # keyboard goodness
        chrysalis

        packages.spot
    ];
  };
}
