{ lib }: with lib; let
  mapping256 = mapAttrs (_: toList) {
    base00 = 0;
    base01 = 18;
    base02 = 19;
    base03 = 8;
    base04 = 20;
    base05 = 7;
    base06 = 21;
    base07 = 15;
    base08 = [ 1 9 ];
    base09 = 16;
    base0A = [ 3 11 ];
    base0B = [ 2 10 ];
    base0C = [ 6 14 ];
    base0D = [ 4 12 ];
    base0E = [ 5 13 ];
    base0F = 17;
    # TODO: support extensions beyond 21?
  };
  mapping16 = {
    base00 = 0;
    base01 = 10;
    base02 = 11;
    base03 = 8;
    base04 = 12;
    base05 = 7;
    base06 = 13;
    base07 = 15;
    base08 = 1;
    base09 = 9;
    base0A = 3;
    base0B = 2;
    base0C = 6;
    base0D = 4;
    base0E = 5;
    base0F = 14;
  };
  ansi = {
    escape = {
      tmux = cmd: ''\ePtmux;\e\e]${cmd}\e\e\\\e\\'';
      screen = cmd: ''\eP\e]${cmd}\007\e\\'';
      generic = cmd: ''\e]${cmd}\e\\'';
    };
    /*commands = {
      colour = {
        "256a" = { ty ? "4;${toString idx}", idx ? null, colour }: ''${ty};rgba:${colour.r16}/${colour.g16}/${colour.b16}/${colour.a16}'';
        # TODO: 256-16? can't remember if urxvt supports that...
        "256" = { ty ? "4;${toString idx}", idx ? null, colour }: ''${ty};rgb:${colour.r}/${colour.g}/${colour.b}'';
        "16" = { idx, hex }: assert idx < 16; ''P${toHexUpper idx}${colour.rgb}'';
      };
    };*/
  };
  /*escape = { mode, ty ? null, idx ? null, value }: let
    esc' = mode:
      base16.shell.escape.mode.${mode} ({ inherit idx; inherit (value) hex; } // optionalAttrs (ty != null) { inherit ty; });
  in optional (idx != null && idx < 16 && mode == "16") (esc' "16")
    ++ optional (mode == "256a" && (value.hasAlpha || value.has16bit)) (esc' "256a")
    ++ optional (mode == "256a" || mode == "256") (esc' "256");*/
  /*escapes = { mode, colours }:
    concatLists (imap0 (idx: value: escape { inherit mode idx value; }) colours);
  cEscapes = { cmd, mode }: map cmd (escapes { inherit mode; inherit (self) colours; });
  escapes = mapAttrs (_: cmd: rec {
    colours = concatStrings (cEscapes { inherit cmd; inherit (self) mode; });
    colours16 = concatStrings (cEscapes { inherit cmd; mode = "16"; });
    commands = concatStrings (cmdEscapes { inherit cmd; inherit (self) mode; });
    iterm2 = concatStrings (mapAttrsToList (_: v: cmd "${v.cmd}${v.value.hex.rgb}") self.iterm2);
    all = colours + commands;
  }) base16.shell.escape.term;*/
  ansiEscapeModule = { config, ... }: {
    options = {
      command = mkOption {
        type = types.str;
      };
      escape = mapAttrs (_: esc: mkOption {
        type = types.str;
        default = esc config.command;
      }) base16.shell.ansi.escape;
    };
  };
  ansiColourModule = { config, ... }: {
    imports = [
      ansiEscapeModule
    ];

    options = {
      type = mkOption {
        type = types.str;
        default = if config.palette == 16
          then "P${toHexUpper config.index}"
          else "4;${toString config.index}";
      };
      index = mkOption {
        type = types.int;
      };
      colour = mkOption {
        type = base16.types.colourType;
      };
      palette = mkOption {
        type = types.enum [ 16 256 ];
        default = 16;
      };
      mode = mkOption {
        type = types.enum [ "hex" "xparsecolor" ];
        default = if config.palette == 16 then "hex" else "xparsecolor";
      };
      command = mkOption {
        type = types.str;
      };
    };
    config = {
      command = mkOptionDefault (config.type + (if config.mode == "hex" then config.colour.rgb
        else if config.colour.hasAlpha then '';rgba:${config.colour.r16}/${config.colour.g16}/${config.colour.b16}/${config.colour.a16}''
        else '';rgb:${config.colour.r}/${config.colour.g}/${config.colour.b}''
      ));
    };
  };
  shellPaletteModule = { config, ... }: {
    options = {
      palette = mkOption {
        type = with types; lazyAttrsOf base16.types.colourType;
        default = { };
      };
      termPalette = mkOption {
        type = types.enum [ 16 256 ];
        default = 256;
      };
      colours = mkOption {
        type = with types; attrsOf (listOf (submodule ansiColourModule));
        default = [ ];
      };
      escapes = mapAttrs (_: term: mkOption {
        type = with types; attrsOf (separatedString "");
      }) base16.shell.ansi.escape;
      shellScript = mkOption {
        type = types.lines;
      };
      mapping = mkOption {
        type = types.unspecified;
      };
    };
    config = let
      shellScript = colours: ''
        # 16/256 colour space
        if [ -n "$TMUX" ]; then
          echo -en '${config.escapes.tmux.${colours}}${config.escapes.tmux.commands}'
          if [ -n "$ITERM_SESSION_ID" ]; then
            echo -en '${config.escapes.tmux.iterm2}'
          fi
        elif [ "''${TERM%%[-.]*}" = "screen" ]; then
          echo -en '${config.escapes.screen.${colours}}${config.escapes.screen.commands}'
          if [ -n "$ITERM_SESSION_ID" ]; then
            echo -en '${config.escapes.screen.iterm2}'
          fi
        elif [ "''${TERM%%-*}" = "linux" ]; then
          echo -en '${config.escapes.generic.colours16}'
        else
          echo -en '${config.escapes.generic.${colours}}${config.escapes.generic.commands}'
          if [ -n "$ITERM_SESSION_ID" ]; then
            echo -en '${config.escapes.generic.iterm2}'
          fi
        fi
      '';
    in {
      shellScript = shellScript (if config.termPalette == 256 then "colours" else "colours16");
      mapping = if config.termPalette == 256 then mapAttrs (_: head) mapping256 else mapping16;
      palette = {
        foreground = config.palette.base05.set;
        background = config.palette.base00.set;

        rxvt-internal-border-background = config.palette.background.set; # in addition to border, includes space without glyphs
        rxvt-underline = config.palette.base08.set;

        bold = config.palette.base05.set;
        selection = config.palette.base02.set;
        selected-text = config.palette.base05.set;
        cursor = config.palette.base05.set;
        cursor-text = config.palette.base00.set;
      };
      colours = {
        colours = concatLists (mapAttrsToList (base: ind: map (index: {
          colour = config.palette.${base}.set;
          palette = 256;
          inherit index;
        }) ind) base16.shell.mapping256);
        colours16 = mapAttrsToList (base: index: {
          colour = config.palette.${base}.set;
          palette = 16;
          inherit index;
        }) base16.shell.mapping16;
        commands = [
          { type = "10"; mode = "xparsecolor"; colour = config.palette.foreground.set; }
          { type = "11"; mode = "xparsecolor"; colour = config.palette.background.set; }
          # "12": cursor-colour2
          { command = "12;7"; } # cursor (reverse video)
          { type = "17"; mode = "xparsecolor"; colour = config.palette.selection.set; } # highlight-colour
          #{ type = "19"; palette = 256; colour = config.palette.selected-text.set; } # highlight-text-colour
          { type = "708"; mode = "xparsecolor"; colour = config.palette.rxvt-internal-border-background.set; }
          { type = "707"; mode = "xparsecolor"; colour = config.palette.rxvt-underline.set; } # matcher links
          # "706": rxvt-bold
          # "704": rxvt-italic
        ];
        iterm2 = [
          # iTerm2 proprietary escape codes
          { type = "Pg"; colour = config.palette.foreground.set; }
          { type = "Ph"; colour = config.palette.background.set; }
          { type = "Pi"; colour = config.palette.bold.set; }
          { type = "Pj"; colour = config.palette.selection.set; }
          { type = "Pk"; colour = config.palette.selected-text.set; }
          { type = "Pl"; colour = config.palette.cursor.set; }
          { type = "Pm"; colour = config.palette.cursor-text.set; }
        ];
      };
      escapes = let
        mapColour = esc: c: mkMerge (map (c: c.escape.${esc}) c);
        mapEscape = esc: mapAttrs (_: mapColour esc) config.colours;
      in mapAttrs (esc: _: mapEscape esc) base16.shell.ansi.escape;
    };
  };
  shellPaletteType = types.submodule shellPaletteModule;
in {
  inherit ansi mapping16 mapping256
    shellPaletteModule shellPaletteType;
}
