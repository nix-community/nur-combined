{ lib, ... }:

rec {
  inherit (builtins) toJSON;
  inherit (lib) attrNames optionalString mapAttrs escapeShellArg;

  mapSet = f: attrs: toString (
    map
      (name: f name attrs."${name}")
      (attrNames attrs)
  );

  extractJSON = attrs: dir: ''
    mkdir -p ${escapeShellArg dir}
    ${
      mapSet (name: value: ''
        echo ${escapeShellArg (toJSON value)} > ${escapeShellArg dir}/${escapeShellArg name}.json
      '') attrs
    }
  '';
}
