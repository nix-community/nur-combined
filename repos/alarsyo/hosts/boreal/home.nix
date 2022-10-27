{
  config,
  pkgs,
  ...
}: {
  home-manager.users.alarsyo = {
    # Keyboard settings & i3 settings
    my.home.x.enable = true;
    my.home.x.i3bar.temperature.chip = "k10temp-pci-*";
    my.home.x.i3bar.temperature.inputs = ["Tccd1"];
    my.home.x.i3bar.networking.throughput_interfaces = ["enp8s0" "wlp4s0"];
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
        lilypond-with-fonts
        ;

      inherit (pkgs.packages) spot;
    };
  };
}
