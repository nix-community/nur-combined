{ pkgs ? import <nixpkgs> { } }:
let
  script = "''\"$cmd\" \"\$@\"''";
in
pkgs.writeShellScriptBin "fhsctl" ''
  set -eu -o pipefail

  function help {
      echo "$0 [...packages] -- command [...arguments]"
      exit 1
  }

  function exitHandler {
      [ "0" != "$?" ] && help
  }

  trap 'exitHandler' exit

  packages=""
  while [ ! "$1" == "--" ]
  do
      packages="$packages $1"
      shift
  done
  shift # ignore --

  tempfile=$(mktemp /tmp/fhsctl-XXXXXX.nix)
  cmd="$(readlink $(which $1) -m)";shift
  fhsname="fhsctl-$RANDOM"

  echo $tempfile

  trap - ERR

  echo 'with import <nixpkgs> {};' >> $tempfile
  echo 'buildFHSUserEnv {' >> $tempfile
  echo "name = \"$fhsname\";" >> $tempfile
  echo "targetPkgs = pkgs: with pkgs; [" >> $tempfile
  echo "$packages" >> $tempfile
  echo "];" >> $tempfile
  echo "runScript = ${script};" >> $tempfile
  echo "}" >> $tempfile

  out=$(nix-store -r $(nix-instantiate $tempfile))

  $out/bin/$fhsname "$@"
''
