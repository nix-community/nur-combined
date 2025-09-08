{ pkgs }:

with pkgs.lib;
{
  # Takes a list of names and returns each name's .enable=true; attr.
  # Example: hardware = enables [ "bluetooth" "graphics" "rtl-sdr" ] expands to { bluetooth.enable = true; graphics.enable = true; rtl-sdr.enable = true; }
  enables = names: builtins.listToAttrs (map (n: { name = n; value = { enable = true; }; }) names);
}
