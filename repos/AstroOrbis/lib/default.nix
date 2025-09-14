{ pkgs }:

with pkgs.lib;
{

  # Sets every specified key to one specified value.
  # Example: setAll ["a" "b" "c"] 5 expands to { a = 5; b = 5; c = 5; }
  setAll = names: value:
    builtins.listToAttrs (
      map
        (n: {
          name = n;
          value = value;
        })
        names
    );

  # Takes a list of names and returns each name's .enable=true; attr.
  # Example: hardware = enables [ "bluetooth" "graphics" "rtl-sdr" ] expands to { bluetooth.enable = true; graphics.enable = true; rtl-sdr.enable = true; }
  enables =
    names:
    setAll names {
      enable = true;
    };

}
