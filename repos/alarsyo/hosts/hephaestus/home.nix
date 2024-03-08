{
  config,
  pkgs,
  ...
}: {
  home-manager.users.alarsyo = {
    home.stateVersion = "23.05";
    my.home.laptop.enable = true;

    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3.enable = true;
    my.home.x.i3bar.temperature.chip = "k10temp-pci-*";
    my.home.x.i3bar.temperature.inputs = ["Tctl"];
    my.home.x.i3bar.networking.throughput_interfaces = ["wlp3s0" "enp6s0f3u1u1"];
    my.home.emacs.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;

    # TODO: place in global home conf
    services.dunst.enable = true;

    home.packages = builtins.attrValues {
      inherit
        (pkgs)
        # some websites only work there :(
        
        chromium
        darktable
        # dev
        
        rustup
        gdb
        valgrind
        zotero
        ;

      inherit
        (pkgs.packages)
        ansel
        spot
        ;

      inherit (pkgs.wineWowPackages) stable;
    };
  };
}
