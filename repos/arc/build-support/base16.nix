{ self, super, lib, ... }: with lib; {
  base16 = makeOrExtend super "base16" (base16: base16s: {
    schemesRev = "3102baa6a561de036d5253cf608dd02cd17f0c77";
    schemesSha256 = "09cyvbpmr0pbqsyjgg52pw0srs29kj79m3185vd6hz0xip55yn3n";
    schemesSrc = makeOverridable fetchTarball {
      url = "https://github.com/chriskempson/base16-schemes-source/archive/${base16.schemesRev}.tar.gz";
      sha256 = base16.schemesSha256;
    };
    templatesRev = "d64c224827e1c0d76f45918d78b08631bec03897";
    templatesSha256 = "0ksvvmfmkbd3i0fs5c3a099q4c8jmanzjlq3cq0vv02p4w3zmsrk";
    templatesSrc = makeOverridable fetchTarball {
      url = "https://github.com/chriskempson/base16-templates-source/archive/${base16.templatesRev}.tar.gz";
      sha256 = base16.templatesSha256;
    };
    parseList = let
      schemeData = _: url:
        if hasPrefix "https://github.com" url then fetchTarball {
          url = "${url}/archive/${base16.schemePins.rev or "master"}.tar.gz";
          ${mapNullable (_: "sha256") base16.schemePins.sha256 or null} = base16.schemePins.sha256;
        } else throw ''Unknown base16 url ${url}'';
    in mapAttrs schemeData;
    schemeSrcs = makeOrExtend base16s "schemeSrcs" (base16.parseList (importYAML "${base16.schemesSrc}/list.yaml"));
    templateSrcs = makeOrExtend base16s "templateSrcs" (base16.parseList (importYAML "${base16.templatesSrc}/list.yaml"));
    schemes = foldAttrList (mapAttrsToList (_: s: s.scheme) base16.scheme);
    scheme = mapAttrs (key: src: let
        dir = builtins.readDir "${src}";
        yamlFilter = k: ty: hasSuffix ".yaml" k && ty != "directory";
        slug = k: replaceStrings [ " " ] [ "-" ] (removeSuffix ".yaml" (toLower k));
        file = mapAttrs' (k: _: nameValuePair (slug k) "${src}/${k}") (filterAttrs yamlFilter dir);
        raw = mapAttrs (_: importYAML) file;
        scheme = mapAttrs base16.parseScheme raw;
      in scheme // optionalAttrs (scheme ? ${key}) (scheme.${key} // { default = scheme.${key}; }) // {
        inherit file raw scheme;
      }
    ) base16.schemeSrcs;
    template = mapAttrs (key: src: let
        hackParser = file: let
          string = builtins.readFile file;
          pattern = "([^\n:]+):((\n +([^\n]*))+)(\n|)";
          split = filter isList (builtins.split pattern string);
          deindent = string: concatStringsSep "\n" (filter isString (builtins.split "\n +" string));
        in mapListToAttrs (s: nameValuePair (elemAt s 0) (fromYAML (deindent (elemAt s 1)))) split;
        #config = importYAML "${src}/templates/config.yaml";
        config = hackParser "${src}/templates/config.yaml";
      in scheme: mapAttrs (file: { extension, output }: let
          replacements = mapAttrs' (k: nameValuePair "{{${k}}}") scheme.templateData;
          template = "${src}/templates/${file}.mustache";
          json = builtins.toJSON scheme.templateData;
          unsupported = [ "{{#" "{{/" "{{^" "{{!" "{{>" "{{=" ];
          templateString = builtins.readFile template;
          name = "base16-${key}-${file}-${scheme.scheme-slug}${extension}";
          templateAssert = if replaceStrings unsupported (map (_: "") unsupported) templateString != templateString
            # TODO: if this fails, can we fall back to readFile "${drv}"?
            then throw "base16: template ${key}-${file}${extension} uses unsupported mustache directives"
            else templateString;
          content = replaceStrings (attrNames replacements) (map toString (attrValues replacements)) templateAssert;
        in self.stdenvNoCC.mkDerivation {
          inherit name;
          inherit template json;
          passAsFile = [ "json" ];
          nativeBuildInputs = [ self.mustache ];
          buildCommand = ''
            mustache $jsonPath $template > $out
          '';
          passthru = {
            inherit content;
          };
        }
      ) config
    ) base16.templateSrcs;
    parseScheme = scheme-slug: data: makeExtensible (sself: let
      bases = map (c: "base0${toUpper c}") hexChars;
      stripped = builtins.removeAttrs data ([ "scheme" "author" ] ++ bases);
      base = mapListToAttrs (base: let
        self = sself.${base};
        subhex = off: len: substring off len self.hex.rgba;
      in nameValuePair base {
        hex = {
          raw = toLower data.${base};
          rgba16 =
            if stringLength self.hex.raw == 16 then self.hex.raw
            else if stringLength self.hex.raw == 12 then "${self.hex.raw}ffff"
            else "${self.hex.r}${self.hex.r}${self.hex.g}${self.hex.g}${self.hex.b}${self.hex.b}${self.hex.a}${self.hex.a}";
          rgba =
            if stringLength self.hex.raw == 8 then self.hex.raw
            else if stringLength self.hex.raw == 6 then "${self.hex.raw}ff"
            else throw ''base16 unsupported value "${self.hex.raw}"'';
          rgb = substring 0 6 self.hex.rgba;
          rgb16 = substring 0 12 self.hex.rgba16;
          bgr = "${self.hex.b}${self.hex.g}${self.hex.r}";
          bgr16 = "${self.hex.b16}${self.hex.g16}${self.hex.r16}";
          r = substring 0 2 self.hex.rgba;
          g = substring 2 2 self.hex.rgba;
          b = substring 4 2 self.hex.rgba;
          a = substring 6 2 self.hex.rgba;
          r16 = substring 0 4 self.hex.rgba16;
          g16 = substring 4 4 self.hex.rgba16;
          b16 = substring 8 4 self.hex.rgba16;
          a16 = substring 12 4 self.hex.rgba16;
        };
        rgb = mapAttrs (_: hexToInt) { inherit (self.hex) r16 r g16 g b16 b a16 a; };
        dec = mapAttrs (_: v: v / 65535.0) (with self.rgb; { r = r16; g = g16; b = b16; });
        hasAlpha = self.rgb.a16 != 65535;
        has16bit = stringLength self.hex.raw > 8;
      }) bases;
      metadata = {
        inherit scheme-slug;
      } // optionalAttrs (data ? scheme) { scheme-name = data.scheme; }
      // optionalAttrs (data ? author) { scheme-author = data.author; };
      templateData = stripped // metadata // foldAttrList (map (base: let
        value = sself.${base};
      in {
        "${base}-hex" = value.hex.rgb;
        "${base}-hex-bgr" = value.hex.bgr;
        "${base}-hex-r" = value.hex.r;
        "${base}-hex-g" = value.hex.g;
        "${base}-hex-b" = value.hex.b;
        "${base}-rgb-r" = value.rgb.r;
        "${base}-rgb-g" = value.rgb.g;
        "${base}-rgb-b" = value.rgb.b;
        "${base}-dec-r" = value.dec.r;
        "${base}-dec-g" = value.dec.g;
        "${base}-dec-b" = value.dec.b;
      }) bases);
    in stripped // metadata // {
      inherit templateData;
      scheme-name = data.scheme or (throw "base16 theme name missing");
      scheme-author = data.author or (throw "base16 theme author missing");
      shell = base16.shell.forScheme { scheme = sself; };
      template = mapAttrs (_: template: template sself) base16.template;
    } // base);
    shell = let
      mapshell = _: { shell ? head shells, shells ? [ shell ] }: { inherit shell shells; };
      mapping256 = invertAttrs (mapAttrs mapshell {
        base00.shell = 0;
        base01.shell = 18;
        base02.shell = 19;
        base03.shell = 8;
        base04.shell = 20;
        base05.shell = 7;
        base06.shell = 21;
        base07.shell = 15;
        base08.shells = [ 1 9 ];
        base09.shell = 16;
        base0A.shells = [ 3 11 ];
        base0B.shells = [ 2 10 ];
        base0C.shells = [ 6 14 ];
        base0D.shells = [ 4 12 ];
        base0E.shells = [ 5 13 ];
        base0F.shell = 17;
        # TODO: support extensions beyond 21?
      });
      mapping16 = invertAttrs (mapAttrs mapshell {
        base00.shell = 0;
        base01.shell = 10;
        base02.shell = 11;
        base03.shell = 8;
        base04.shell = 12;
        base05.shell = 7;
        base06.shell = 13;
        base07.shell = 15;
        base08.shell = 1;
        base09.shell = 9;
        base0A.shell = 3;
        base0B.shell = 2;
        base0C.shell = 6;
        base0D.shell = 4;
        base0E.shell = 5;
        base0F.shell = 14;
        # TODO: support extensions beyond 21?
      });
      pairs256 = concatLists (mapAttrsToList (name: value: map (value: { inherit name value; }) value) base16.shell.shells256);
      pairs16 = mapAttrsToList (name: value: { inherit name value; }) base16.shell.shell16;
      escape = { mode, ty ? null, idx ? null, value }: let
        esc' = mode:
          base16.shell.escape.mode.${mode} ({ inherit idx; inherit (value) hex; } // optionalAttrs (ty != null) { inherit ty; });
      in optional (idx != null && idx < 16 && mode == "16") (esc' "16")
        ++ optional (mode == "256a" && (value.hasAlpha || value.has16bit)) (esc' "256a")
        ++ optional (mode == "256a" || mode == "256") (esc' "256");
      escapes = { mode, colours }:
        concatLists (imap0 (idx: value: escape { inherit mode idx value; }) colours);
      forScheme = { scheme, mode ? "256a", ansiCompatibility ? true }: makeExtensible (self: let
        cEscapes = { cmd, mode }: map cmd (escapes { inherit mode; inherit (self) colours; });
        cmdEscapes = { cmd, mode }: concatLists (
          mapAttrsToList (_: v: map cmd (
            if isString v then [ v ]
            else escape {
              inherit mode;
              inherit (v) ty value;
            }
          )) self.commands);
        pairs = (if self.ansiCompatibility then pairs256 else pairs16);
      in {
        inherit scheme;
        colours = map ({ name, ... }: self.scheme.${name}) (sort (a: b: a.value < b.value) pairs);
        colours16 = sublist 0 16 self.colours;
        inherit mode ansiCompatibility;
        commands = {
          cursor = "12;7"; # reverse video
          foreground = { ty = "10"; value = self.scheme.base05; };
          background = { ty = "11"; value = self.scheme.base00; };
          background-rxvt-internal-border = { ty = "708"; value = self.scheme.base00; };
        };
        iterm2 = {
          # iTerm2 proprietary escape codes
          foreground = { cmd = "Pg"; value = self.scheme.base05; };
          background = { cmd = "Ph"; value = self.scheme.base00; };
          bold = { cmd = "Pi"; value = self.scheme.base05; };
          selection = { cmd = "Pj"; value = self.scheme.base02; };
          selected-text = { cmd = "Pk"; value = self.scheme.base05; };
          cursor = { cmd = "Pl"; value = self.scheme.base05; };
          cursor-text = { cmd = "Pm"; value = self.scheme.base00; };
        };
        escapes = mapAttrs (_: cmd: rec {
          colours = concatStrings (cEscapes { inherit cmd; inherit (self) mode; });
          colours16 = concatStrings (cEscapes { inherit cmd; mode = "16"; });
          commands = concatStrings (cmdEscapes { inherit cmd; inherit (self) mode; });
          iterm2 = concatStrings (mapAttrsToList (_: v: cmd "${v.cmd}${v.value.hex.rgb}") self.iterm2);
          all = colours + commands;
        }) base16.shell.escape.term;
        script = ''
          # 16/256 colour space
          if [ -n "$TMUX" ]; then
            echo -en '${self.escapes.tmux.all}'
            if [ -n "$ITERM_SESSION_ID" ]; then
              echo -en '${self.escapes.tmux.iterm2}'
            fi
          elif [ "''${TERM%%[-.]*}" = "screen" ]; then
            echo -en '${self.escapes.screen.all}'
            if [ -n "$ITERM_SESSION_ID" ]; then
              echo -en '${self.escapes.screen.iterm2}'
            fi
          elif [ "''${TERM%%-*}" = "linux" ]; then
            echo -en '${self.escapes.generic.colours16}'
          else
            echo -en '${self.escapes.generic.all}'
            if [ -n "$ITERM_SESSION_ID" ]; then
              echo -en '${self.escapes.screen.iterm2}'
            fi
          fi
        '';
      });
    in {
      shells256 = mapping256.shells;
      shell256 = mapping256.shell;
      shell16 = mapping16.shell;
      forScheme = makeOverridable forScheme;
      escape = {
        term = {
          tmux = cmd: ''\ePtmux;\e\e]${cmd}\e\e\\\e\\'';
          screen = cmd: ''\eP\e]${cmd}\007\e\\'';
          generic = cmd: ''\e]${cmd}\e\\'';
        };
        mode = {
          "256a" = { ty ? "4;${toString idx}", idx ? null, hex }: ''${ty};rgba:${hex.r16}/${hex.g16}/${hex.b16}/${hex.a16}'';
          # TODO: 256-16? can't remember if urxvt supports that...
          "256" = { ty ? "4;${toString idx}", idx ? null, hex }: ''${ty};rgb:${hex.r}/${hex.g}/${hex.b}'';
          "16" = { idx, hex }: assert idx < 16; ''P${toHexUpper idx}${hex.rgb}'';
        };
      };
    } // mapping256.shell;
  });
}
