{
  lib,
  runCommand,
  coreutils,
  mq,
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
  writeText,
}:

let
  inherit ((import ./_sources/generated.nix {
      inherit
        fetchgit
        fetchurl
        fetchFromGitHub
        dockerTools
        ;
    }).yazi-rs-plugins) src;
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
