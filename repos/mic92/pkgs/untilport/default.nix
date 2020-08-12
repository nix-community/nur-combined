{ stdenv, netcat, writeScriptBin }:

(writeScriptBin "untilport" ''
  #!${stdenv.shell}
  set -euf

  if [ $# -ne 2 ]; then
    echo 'untiport $target $port'
    echo 'Sleeps until the destinated port is reachable.'
    echo 'ex: untilport google.de 80 && echo "google is now reachable"'
  else
    until ${netcat}/bin/nc -z "$@"; do sleep 1; done
  fi
'') // {
  meta = {
    description = "Wait until tcp port is reachable";
  };
}
