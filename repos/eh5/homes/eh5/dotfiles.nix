{ lib, ... }:
{
  home.file.".actrc".text = ''
    -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
    -P ubuntu-20.04=ghcr.io/catthehacker/ubuntu:act-20.04
    -P ubuntu-18.04=ghcr.io/catthehacker/ubuntu:act-18.04
  '';
  home.file.".screenrc".text = ''
    defscrollback 100000
    termcapinfo xterm ti@:te@
  '';
}
