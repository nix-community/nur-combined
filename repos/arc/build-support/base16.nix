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
          filtered = builtins.removeAttrs scheme ([ "raw" "file" "scheme" "default" ] ++ attrNames scheme.scheme or {});
          replacements = mapAttrs' (k: nameValuePair "{{${k}}}") filtered;
          template = "${src}/templates/${file}.mustache";
          json = builtins.toJSON filtered;
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
    parseScheme = slug: data: let
      bases = [ "0" "1" "2" "3" "4" "5" "6" "7" "8" "9" "A" "B" "C" "D" "E" "F" ];
      stripped = builtins.removeAttrs data ([ "scheme" "author" ] ++ map (b: "base0${b}") bases);
    in foldAttrList ([ stripped base16.shellScheme {
      scheme-name = data.scheme or (throw "base16 theme name missing");
      scheme-author = data.author or (throw "base16 theme author missing");
      scheme-slug = slug;
    } ] ++ map (base: let
      id = "0${base}";
      hex = data."base${id}";
      subhex = off: toLower (substring off 2 hex);
      rgb = {
        r = subhex 0;
        g = subhex 2;
        b = subhex 4;
      };
      hexchar = char: let
        pairs = imap0 (flip nameValuePair) bases;
        idx = listToAttrs pairs;
      in idx.${toUpper char};
      hex2int = str:
        foldr (chr: value: value * 16 + hexchar chr) 0 (stringToCharacters str);
      int = mapAttrs (_: hex2int) rgb;
      dec = mapAttrs (_: v: v / 255.0) int;
    in stripped // {
      "base${id}-hex" = hex;
      "base${id}-hex-bgr" = "${rgb.b}${rgb.g}${rgb.r}";
      "base${id}-hex-r" = rgb.r;
      "base${id}-hex-g" = rgb.g;
      "base${id}-hex-b" = rgb.b;
      "base${id}-rgb-r" = int.r;
      "base${id}-rgb-g" = int.g;
      "base${id}-rgb-b" = int.b;
      "base${id}-dec-r" = dec.r;
      "base${id}-dec-g" = dec.g;
      "base${id}-dec-b" = dec.b;
    }) bases);
    shellScheme = {
      base00-256 = 0;
      base01-256 = 18;
      base02-256 = 19;
      base03-256 = 8;
      base04-256 = 20;
      base05-256 = 7;
      base06-256 = 21;
      base07-256 = 15;
      base08-256 = 1;
      base09-256 = 16;
      base0A-256 = 3;
      base0B-256 = 2;
      base0C-256 = 6;
      base0D-256 = 4;
      base0E-256 = 5;
      base0F-256 = 17;
      # TODO: support extensions beyond 21?
    };
  });
}
