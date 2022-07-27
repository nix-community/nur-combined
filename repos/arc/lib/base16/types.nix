{ lib }: with lib; let
  colourValueType = with types; oneOf [ str ints.u8 ];
  colourComponentModule = { options, config, ... }: let
    calculated16 = byte: byte * 256 + (if byte >= 128 then 255 else 0); # skews the value toward 0 or 0xffff
    calculated8 = nibble: nibble * 16 + (if byte >= 8 then 15 else 0); # skews the value toward 0 or 0xff
  in {
    options = {
      value = mkOption {
        type = colourValueType;
      };
      hex4 = mkOption {
        type = types.str;
        default = toHex config.nibble;
      };
      hex = mkOption {
        type = types.str;
        default = fixedWidthString 2 "0" (toHex config.byte);
      };
      hex16 = mkOption {
        type = types.str;
        default = fixedWidthString 4 "0" (toHex config.int16);
      };
      nibble = mkOption {
        type = types.ints.between 0 15;
        default = config.byte / 16;
        readOnly = true;
      };
      byte = mkOption {
        type = types.ints.u8;
        default = config.int16 / 256;
      };
      int16 = mkOption {
        type = types.ints.u16;
        default = calculated16 config.byte;
      };
      dec = mkOption {
        type = types.float;
        default = config.int16 / 65535.0;
        readOnly = true;
      };
      has16Bit = mkOption {
        type = types.bool;
        default = config.int16 != calculated16 config.byte;
      };
      set = mkOption {
        type = types.unspecified;
      };
    };
    config = {
      byte = mkMerge [
        (mkIf (options.value.isDefined && isInt config.value) (mkDefault config.value))
        (mkIf (options.value.isDefined && isString config.value && stringLength config.value == 2) (mkDefault (hexToInt config.value)))
        (mkIf (options.value.isDefined && isString config.value && stringLength config.value < 2) (mkDefault (calculated8 (hexToInt config.value))))
      ];
      int16 = mkIf (options.value.isDefined && isString config.value && stringLength config.value > 2) (mkDefault (hexToInt config.value));
      set = mapAttrs (_: mkDefault) (if config.has16Bit then {
        inherit (config) int16;
      } else {
        inherit (config) byte;
      });
    };
  };
  colourComponentType = with types; coercedTo colourValueType (value: { inherit value; }) (submodule colourComponentModule);
  colourModule = { options, config, ... }: {
    options = {
      value = mkOption {
        type = types.str;
      };
      red = mkOption {
        type = colourComponentType;
        default = { };
      };
      green = mkOption {
        type = colourComponentType;
        default = { };
      };
      blue = mkOption {
        type = colourComponentType;
        default = { };
      };
      alpha = mkOption {
        type = colourComponentType;
        default = { byte = mkDefault 255; };
      };
      r = mkOption {
        type = types.str;
        default = config.red.hex;
      };
      r4 = mkOption {
        type = types.str;
        default = config.red.hex4;
      };
      r16 = mkOption {
        type = types.str;
        default = config.red.hex16;
      };
      g = mkOption {
        type = types.str;
        default = config.green.hex;
      };
      g4 = mkOption {
        type = types.str;
        default = config.green.hex4;
      };
      g16 = mkOption {
        type = types.str;
        default = config.green.hex16;
      };
      b = mkOption {
        type = types.str;
        default = config.blue.hex;
      };
      b4 = mkOption {
        type = types.str;
        default = config.blue.hex4;
      };
      b16 = mkOption {
        type = types.str;
        default = config.blue.hex16;
      };
      a = mkOption {
        type = types.str;
        default = config.alpha.hex;
      };
      a4 = mkOption {
        type = types.str;
        default = config.alpha.hex4;
      };
      a16 = mkOption {
        type = types.str;
        default = config.alpha.hex16;
      };
      hex = mkOption {
        type = types.str;
        default = if config.has16Bit
          then config.rgb_16
          else config.rgb_;
      };
      rgb = mkOption {
        type = types.str;
        default = "${config.r}${config.g}${config.b}";
      };
      rgb16 = mkOption {
        type = types.str;
        default = "${config.r16}${config.g16}${config.b16}";
      };
      bgr = mkOption {
        type = types.str;
        default = "${config.b}${config.g}${config.r}";
      };
      bgr16 = mkOption {
        type = types.str;
        default = "${config.b16}${config.g16}${config.r16}";
      };
      rgba = mkOption {
        type = types.str;
        default = config.rgb + config.a;
      };
      rgb_ = mkOption {
        type = types.str;
        default = config.rgb + optionalString config.hasAlpha config.a;
      };
      rgba16 = mkOption {
        type = types.str;
        default = config.rgb16 + config.a16;
      };
      rgb_16 = mkOption {
        type = types.str;
        default = config.rgb16 + optionalString config.hasAlpha config.a16;
      };
      argb = mkOption {
        type = types.str;
        default = config.a + config.rgb;
      };
      _rgb = mkOption {
        type = types.str;
        default = optionalString config.hasAlpha config.a + config.rgb;
      };
      argb16 = mkOption {
        type = types.str;
        default = config.a16 + config.rgb16;
      };
      _rgb16 = mkOption {
        type = types.str;
        default = optionalString config.hasAlpha config.a16 + config.rgb;
      };
      bgra = mkOption {
        type = types.str;
        default = config.bgr + config.a;
      };
      bgr_ = mkOption {
        type = types.str;
        default = config.bgr + optionalString config.hasAlpha config.a;
      };
      bgra16 = mkOption {
        type = types.str;
        default = config.bgr16 + config.a16;
      };
      bgr_16 = mkOption {
        type = types.str;
        default = config.bgr16 + optionalString config.hasAlpha config.a16;
      };
      hasAlpha = mkOption {
        type = types.bool;
        #default = config.a != "ff";
        default = config.alpha.int16 != 65535;
      };
      has16Bit = mkOption {
        type = types.bool;
        default = any (c: c.has16Bit) [ config.red config.green config.blue config.alpha ];
      };
      set = mkOption {
        type = types.unspecified;
      };
    };
    config = let
      mult = if stringLength config.value > 8 then 4 else if stringLength config.value > 4 then 2 else 1;
      hasAlpha = stringLength config.value > 3 * mult;
      component = offset: substring (offset * mult) mult config.value;
    in mkMerge [
      (mkIf options.value.isDefined {
        red = mkDefault (component 0);
        green = mkDefault (component 1);
        blue = mkDefault (component 2);
        alpha = mkIf hasAlpha (mkDefault (component 3));
      })
      {
        set = mapAttrs (_: mkDefault) {
          red = config.red.set;
          green = config.green.set;
          blue = config.blue.set;
          alpha = config.alpha.set;
        };
      }
    ];
  };
  colourType = with types; coercedTo str (value: { inherit value; }) (submodule colourModule);
  templateModule = { config, ... }: {
    options.templateData = mkOption {
      type = with types; lazyAttrsOf str;
    };
    config.templateData = let
      templatedBases = map (base: let
        value = config.${base};
      in mapAttrs (_: v: mkOptionDefault (toString v)) {
        "${base}-hex" = value.rgb;
        "${base}-hex-bgr" = value.bgr;
        "${base}-hex-r" = value.r;
        "${base}-hex-g" = value.g;
        "${base}-hex-b" = value.b;
        "${base}-rgb-r" = value.red.byte;
        "${base}-rgb-g" = value.green.byte;
        "${base}-rgb-b" = value.blue.byte;
        "${base}-dec-r" = value.red.dec;
        "${base}-dec-g" = value.green.dec;
        "${base}-dec-b" = value.blue.dec;
      }) base16.names;
    in mkMerge (templatedBases ++ singleton {
      scheme-name = mkOptionDefault config.scheme;
      scheme-author = mkIf (config.author != null) (mkOptionDefault config.author);
      scheme-slug = mkOptionDefault config.slug;
    });
  };
  aliasModule = { config, ... }: {
    options.aliases = mkOption {
      type = with types; lazyAttrsOf unspecified;
    };
    config.aliases = {
      background = config.base00;
      background_light = config.base01;
      background_status = config.base01;
      background_selection = config.base02;
      comment = config.base03;
      highlight = config.base03;
      foreground_dark = config.base04;
      foreground_status = config.base04;
      foreground = config.base05;
      caret = config.base05;
      delimiter = config.base05;
      operator = config.base05;
      foreground_alt = config.base06; # called "light", not often used?
      background_alt = config.base07; # called "light", not often used?
      variable = config.base08;
      link = config.base08;
      ident = config.base08;
      deleted = config.base08;
      constant = config.base09;
      integer = config.base09;
      boolean = config.base09;
      url = config.base09;
      class = config.base0A;
      bold = config.base0A;
      background_search = config.base0A;
      string = config.base0B;
      inherited = config.base0B;
      code = config.base0B;
      inserted = config.base0B;
      support = config.base0C;
      escape = config.base0C;
      regex = config.base0C;
      quote = config.base0C;
      function = config.base0D;
      method = config.base0D;
      attribute = config.base0D;
      heading = config.base0D;
      keyword = config.base0E;
      storage = config.base0E;
      selector = config.base0E;
      italic = config.base0E;
      changed = config.base0E;
      deprecated = config.base0F;
      tag = config.base0F;
    };
  };
  schemeModule = { options, config, name, ... }: let
    baseOption = name: mkOption {
      type = colourType;
    };
  in {
    options = genAttrs base16.names baseOption // {
      scheme = mkOption {
        type = types.str;
        default = name;
      };
      author = mkOption {
        type = with types; nullOr str;
        default = null;
      };
      slug = mkOption {
        type = types.str;
        default = name;
      };
    };
  };
  schemeType = types.submodule [ schemeModule aliasModule templateModule ];
in {
  inherit colourComponentModule colourComponentType
    colourModule colourType
    schemeModule schemeType
    templateModule aliasModule;
}
