{
  config,
  pkgs,
  ...
}: {
  home-manager.users.alarsyo = {
    my.home.laptop.enable = true;

    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3bar.temperature.chip = "k10temp-pci-*";
    my.home.x.i3bar.temperature.inputs = ["Tccd1"];
    my.home.x.i3bar.networking.throughput_interfaces = ["wlp3s0"];
    my.home.emacs.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;

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
        arandr
        zotero
        ;

      inherit (pkgs.packages) spot;

      inherit (pkgs.wineWowPackages) stable;
    };
  };
}
