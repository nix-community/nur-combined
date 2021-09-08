{ config, pkgs, ... }:
{
  home-manager.users.alarsyo = {
    my.home.laptop.enable = true;

    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3bar.temperature.chip = "coretemp-isa-*";
    my.home.x.i3bar.temperature.inputs = ["Core 0" "Core 1" "Core 2" "Core 3"];
    my.home.x.i3bar.networking.throughput_interfaces = [ "enp0s31f6" "wlp0s20f3" ];
    my.home.emacs.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;

    home.packages = with pkgs; [
        # some websites only work there :(
        chromium

        wineWowPackages.stable

        darktable

        # dev
        rustup

        beancount
        fava

        packages.spot
    ];
  };
}
