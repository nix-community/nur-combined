{ lib, ... }:

{
  dconf.settings = {

    "org/gnome/desktop/wm/keybindings" = {
      show-desktop=["F12"];
    };


#    "org/gnome/desktop/peripherals/mouse" = {
    #natural-scroll = false;
    #speed = -0.5;
    #};

    #"org/gnome/desktop/peripherals/touchpad" = {
    #tap-to-click = false;
    #two-finger-scrolling-enabled = true;
    #};

    #"org/gnome/desktop/input-sources" = {
      #current = "uint32 0";
      #sources = [ (mkTuple [ "xkb" "us" ]) ];
      #xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:ralt_switch" "caps:ctrl_modifier" ];
      #};

      #"org/gnome/desktop/screensaver" = {
        #picture-uri = "file:///home/gvolpe/Pictures/nixos.png";
      #};
#    };

  };
}
