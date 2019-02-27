# This converts some spinners I've shamelessly copied from https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json
# into something that can be used in a shell script
{ lib, runCommand }:

with lib;

let
  spinners = mapAttrsToList (name: v: v // { inherit name; }) (importJSON ./spinners.json);
in runCommand "spinners" {} ''
  mkdir -p $out

  ${concatMapStrings ({name, frames, interval}: ''
  cat <<EOF > $out/${name}
  interval=${toString (interval / 1000.0)}
  frames=(${concatStringsSep " " (map (frame: ''"${frame}"'') frames)})
  EOF
  '') spinners}
''
