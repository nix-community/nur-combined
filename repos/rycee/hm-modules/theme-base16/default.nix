{ config, lib, ... }:

with lib;

let

  cfg = config.theme.base16;

  mkEnableThemeOption = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  toHex2 = let
    hex = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "a" "b" "c" "d" "e" "f" ];
    hexVal = elemAt hex;
  in n: hexVal (mod 16 n) + hexVal (mod 16 (div n 16));

  fromHex = let
    hexes = {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "A" = 10;
      "B" = 11;
      "C" = 12;
      "D" = 13;
      "E" = 14;
      "F" = 15;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    };
  in v: foldl' (acc: x: acc * 16 + hexes.${x}) 0 (stringToCharacters v);

  mkHexColorOption = component:
    mkOption {
      type = types.strMatching "[0-9a-fA-F]{2}";
      example = "b1";
      visible = false;
      description = "The ${component} component value as a hexadecimal string.";
    };

  mkDecColorOption = component:
    mkOption {
      type = types.ints.u8;
      example = 177;
      visible = false;
      description = "The ${component} component value as a hexadecimal string.";
    };

  colorModule = types.submodule ({ config, ... }: {
    options = {
      hex.r = mkHexColorOption "red";
      hex.g = mkHexColorOption "green";
      hex.b = mkHexColorOption "blue";
      hex.rgb = mkOption {
        type = types.strMatching "[0-9a-fA-F]{6}";
        readOnly = true;
        visible = false;
        description = "Concatenated hexadecimal string.";
      };

      dec.r = mkDecColorOption "red";
      dec.g = mkDecColorOption "green";
      dec.b = mkDecColorOption "blue";
    };

    config = {
      hex.r = mkDefault (toHex2 config.dec.r);
      hex.g = mkDefault (toHex2 config.dec.g);
      hex.b = mkDefault (toHex2 config.dec.b);
      hex.rgb = config.hex.r + config.hex.g + config.hex.b;

      dec.r = mkDefault (fromHex config.hex.r);
      dec.g = mkDefault (fromHex config.hex.g);
      dec.b = mkDefault (fromHex config.hex.b);
    };
  });

in {
  meta.maintainers = [ maintainers.rycee ];

  imports = [
    ./bat.nix
    ./dunst.nix
    ./gnome-terminal.nix
    ./gtk.nix
    ./polybar.nix
    ./rofi.nix
  ];

  options = {
    theme.base16 = {
      kind = mkOption {
        type = types.enum [ "dark" "light" ];
        example = "dark";
        default = let inherit (cfg.colors.base00.dec) r g b;
        in if r + g + b >= 382 then "light" else "dark";
        defaultText = literalExample ''
          "light", if sum of RGB components of base00 color ≥ 382,
          "dark", otherwise
        '';
        description = ''
          Whether theme is dark or light. The default value is determined by a
          basic heuristic, if an incorrect value is found then this option must
          be set explicitly.
        '';
      };

      colors = let
        mkHexColorOption = mkOption {
          type = colorModule;
          example = {
            dec = {
              r = 177;
              g = 42;
              b = 42;
            };
          };
          description = ''
            Color value. Either a hexadecimal or decimal RGB triplet must be
            given. If a hexadecimal triplet is given then the decimal triplet is
            automatically populated, and vice versa. That is, the example could
            be equivalently written

            <programlisting language="nix">
              { hex.r = "b1"; hex.g = "2a"; hex.b = "2a"; }
            </programlisting>

            And
            <programlisting language="nix">
              "red dec: ''${dec.r}, red hex: ''${hex.r}, rgb hex: ''${hex.rgb}"
            </programlisting>
            would expand to
            <quote>red dec: 177, red hex: b1, rgb hex: b12a2a</quote>.
          '';
        };
      in {
        base00 = mkHexColorOption;
        base01 = mkHexColorOption;
        base02 = mkHexColorOption;
        base03 = mkHexColorOption;
        base04 = mkHexColorOption;
        base05 = mkHexColorOption;
        base06 = mkHexColorOption;
        base07 = mkHexColorOption;
        base08 = mkHexColorOption;
        base09 = mkHexColorOption;
        base0A = mkHexColorOption;
        base0B = mkHexColorOption;
        base0C = mkHexColorOption;
        base0D = mkHexColorOption;
        base0E = mkHexColorOption;
        base0F = mkHexColorOption;
      };
    };
  };
}
