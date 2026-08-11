# FIXME error: YAML parse failed: ""

{ lib }:

with lib;

let
  # https://github.com/arcnmx/nixexprs/blob/master/lib/default.nix
  # NOTE: a very basic/incomplete parser
  # fromYAML = import ./from-yaml.nix lib;
  # https://github.com/arcnmx/nixexprs/blob/master/lib/from-yaml.nix
  fromYAML = yaml: with lib; let
    stripLine = line: elemAt (builtins.match "([^#]*)(#.*|)" line) 0;
    usefulLine = line: builtins.match "[ \\t]*" line == null;
    parseString = token: let
      match = builtins.match ''([^"]+|"([^"]*)" *)'' token;
    in
      if match == null then throw ''YAML string parse failed: "${token}"''
      else if elemAt match 1 != null then elemAt match 1
      else elemAt match 0;
    attrLine = line: let
      match = builtins.match "([^ :]+): *(.*?) *" line;
    in
      if match == null then throw ''YAML parse failed: "${line}"''
      else nameValuePair (elemAt match 0) (parseString (elemAt match 1));
    lines = splitString "\n" yaml;
    lines' = map stripLine lines;
    lines'' = filter usefulLine lines';
  in mapListToAttrs attrLine lines;

  # https://github.com/arcnmx/nixexprs/blob/master/lib/default.nix
  mapListToAttrs = f: l: listToAttrs (map f l);
in

fromYAML
