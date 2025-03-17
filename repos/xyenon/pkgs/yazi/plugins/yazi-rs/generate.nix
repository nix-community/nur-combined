{
  source,
  lib,
  runCommand,
  coreutils,
  mq,
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
            runCommand "${name}-description" {
              nativeBuildInputs = [
                coreutils
                mq
              ];
            } ''mq -q '.text | gsub("([\\.!])(\\s+|$)", "")' ${src}/${name}/README.md | head -qn 1 > "$out"''
          )
        );
      }
    ) (filterAttrs (n: v: (hasSuffix ".yazi" n) && v == "directory") (builtins.readDir src));
in
writeText "plugins.json" (lib.strings.toJSON plugins)
