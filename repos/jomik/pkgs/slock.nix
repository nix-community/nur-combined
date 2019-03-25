{ pkgs, lib, ... }:

with lib;
let
  path = makeBinPath (with pkgs; [
    coreutils
    i3lock-color
    scrot
    imagemagick
  ]);
in pkgs.writeShellScriptBin "slock" ''
  export PATH=${path}
  screen=/run/user/$UID/screen.png

  convert x:root -scale 5% -sample 2000% -quality 30 $screen
  i3lock-color -n -i $screen \
    --insidecolor=373445ff --ringcolor=ffffffff --line-uses-inside \
    --keyhlcolor=d23c3dff --bshlcolor=d23c3dff --separatorcolor=00000000 \
    --insidevercolor=fecf4dff --insidewrongcolor=d23c3dff \
    --ringvercolor=ffffffff --ringwrongcolor=ffffffff --indpos="x+86:y+1003" \
    --radius=15 --veriftext="" --wrongtext=""

  pid=$!
  wait $pid
  [ -f "$screen" ] && rm $screen
''
