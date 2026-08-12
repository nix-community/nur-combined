{
  source,
  lib,
  runCommand,
  writeText,
}:

let
  inherit (source) src;
  plugins =
    with lib;
    mapAttrs' (
      name: _value:
      nameValuePair (removeSuffix ".yazi" name) {
        description = trim (
          builtins.readFile (
            runCommand "${name}-description" { } ''
              grep -m 1 '^[a-zA-Z\[]' ${src}/${name}/README.md \
                | sed -E 's/^A ([a-zA-Z])/\U\1/' \
                | sed -E 's/[\.!](\s.*)?$//' > "$out"
            ''
          )
        );
      }
    ) (filterAttrs (n: v: (hasSuffix ".yazi" n) && v == "directory") (builtins.readDir src));
in
writeText "plugins.json" (lib.strings.toJSON plugins)
