{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.fonts.powerline-symbols;

  powerlineSymbolsFont = pkgs.linkFarm "powerline-symbols-font" [ {
    name = "share/fonts/opentype/PowerlineSymbols.otf";
    path = pkgs.fetchurl {
      url = https://github.com/powerline/powerline/raw/2.7/font/PowerlineSymbols.otf;
      sha256 = "18gp2mjpc05s3lg9fdh1r5b9dxyrmv17wyh6rrw9hr5i16h9c92a";
    };
  } ];

  # Based on upstream's 10-powerline-symbols.conf
  mkPowerlineSymbolsConf = fonts: pkgs.writeTextFile {
    name = "powerline-symbols-conf";
    destination = "/etc/fonts/conf.d/10-powerline-symbols.conf";
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
      <!-- 'prefer' PowerlineSymbols font, original as fallback for non-powerline symbols -->
      ${concatStringsSep "\n" (map (font: ''
        <alias>
          <family>${font}</family>
          <prefer><family>PowerlineSymbols</family></prefer>
        </alias>
      '') fonts)}
      </fontconfig>
    '';
  };

  powerlineSymbolsConf = mkPowerlineSymbolsConf cfg.fonts;
in
  {
    options.fonts.powerline-symbols = {
      enable = lib.mkEnableOption "PowerlineSymbols font and configuration";
      fonts = mkOption {
        type = types.listOf types.str;
        default = [
          # default family's in 2.7's 10-powerline-symbols.conf
          "monospace"
          "Droid Sans Mono"
          "Droid Sans Mono Slashed"
          "Droid Sans Mono Dotted"
          "DejaVu Sans Mono"
          "DejaVu Sans Mono"
          "Envy Code R"
          "Inconsolata"
          "Lucida Console"
          "Monaco"
          "Pragmata"
          "PragmataPro"
          "Menlo"
          "Source Code Pro"
          "Consolas"
          "Anonymous pro"
          "Bitstream Vera Sans Mono"
          "Liberation Mono"
          "Ubuntu Mono"
          "Meslo LG L"
          "Meslo LG L DZ"
          "Meslo LG M"
          "Meslo LG M DZ"
          "Meslo LG S"
          "Meslo LG S DZ"
          # What motivated this
          "Agave"
        ];
        description = ''
          Font family names that will use glyphs from the PowerlineSymbol font before using original as "fallback".
        '';
      };
    };

    config = mkIf cfg.enable {
      # TODO: check/ensure fontconfig is being used?
      fonts.fontconfig.confPackages = [ powerlineSymbolsConf ];
      fonts.fonts = [ powerlineSymbolsFont ];
    };
  }
