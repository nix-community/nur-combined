{ lib, writeShellScriptBin, coreutils, i3lock, scrot, imagemagick,
  private ? true }:

let
  path = lib.makeBinPath ([
    coreutils
    i3lock
  ] ++ (lib.optionals (!private) [
    scrot
    imagemagick
  ]));
in writeShellScriptBin "slock" ''
  export PATH=${path}

  ${if private then ''
    i3lock --show-failed-attempts -c 000000
  '' else ''
    screen=/run/user/$UID/screen.png
    convert x:root -scale 5% -sample 2000% -quality 30 $screen
    i3lock --show-failed-attempts -i $screen
  ''}

  pid=$!
  wait $pid

  [ -f "$screen" ] && rm -- "$screen"
''
