{ lib }: with lib; {
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
  hackParser = file: let
    string = builtins.readFile file;
    pattern = "([^\n:]+):((\n +([^\n]*))+)(\n|)";
    split = filter isList (builtins.split pattern string);
    deindent = string: concatStringsSep "\n" (filter isString (builtins.split "\n +" string));
  in mapListToAttrs (s: nameValuePair (elemAt s 0) (fromYAML (deindent (elemAt s 1)))) split;
  hackTemplate = src: let
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
    in content
  ) config;
}
