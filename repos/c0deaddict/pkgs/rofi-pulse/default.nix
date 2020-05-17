{ ponymix, my-lib, ... }:

my-lib.wrap {
  name = "rofi-pulse";
  paths = [ ponymix ];
  file = ./rofi-pulse.sh;
}
