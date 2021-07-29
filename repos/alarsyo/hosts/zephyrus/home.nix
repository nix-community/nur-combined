{ config, pkgs, ... }:
{
  home-manager.users.alarsyo = {
    my.home.laptop.enable = true;

    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3bar.temperature.chip = "coretemp-isa-*";
    my.home.x.i3bar.temperature.inputs = ["Core 0" "Core 1" "Core 2" "Core 3"];
    my.home.emacs.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;

    home.packages = with pkgs; [
        # some websites only work there :(
        chromium

        darktable

        # dev
        rustup

        unstable.beancount
        unstable.fava
    ];
  };
}
