{ lib }:
with builtins;

let

  # print YAML string

  # the output is not pretty, but it should be valid YAML

  # test:
  # nix-shell -p yaml2json
  # ./bin/to-yaml.nix.sh | yaml2json | jq

  toYAML = let
    toYAMLInner = indent: node: (
      #let nodeType = builtins.typeOf; in
      #if node == null then "null" else
      #if node == true then "true" else
      #if node == false then "false" else
      #if builtins.isString node then builtins.toJSON node else
      if builtins.isList node then (
        lib.concatStrings (
          builtins.map
          (item: indent + "-\n" + (toYAMLInner (indent + "  ") item))
          node
        )
      ) else
      if builtins.isAttrs node then (
        #printAttribute = name: value: ''${indent}    ${name}: ${toJSON value}'' + "\n";
        let
          #printAttribute = name: value: (indent + "  " + (builtins.toJSON name) + ": " + (toYAMLInner (indent + "  ") value) + "\n");
          printAttribute = name: value: (indent + (builtins.toJSON name) + ":\n" + (toYAMLInner (indent + "  ") value) + "\n");
        in
        lib.concatStrings (lib.mapAttrsToList printAttribute node)
      ) else
      if builtins.isFunction node then throw "cannot convert a function to YAML" else
      (indent + (builtins.toJSON node))
      #throw "cannot convert type ${builtins.typeOf node} to YAML"
    );
    in node: (toYAMLInner "" node);

in

toYAML
