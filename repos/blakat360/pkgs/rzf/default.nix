{ pkgs ? import <nixpkgs> }:
# let
#   rzf =
#     pkgs.writeShellApplication {
#       name = "rzf";
#       runtimeInputs = with pkgs; [ fzf rofi ];
#       text = ''
#         if [ "$TERM" == 'screen' ]; then
#           fzf-tmux
#         else
#         	rofi -dmenu
#         fi
#       '';
#     };
# in
# pkgs.stdenv.mkDerivation rec {
#   name = "rzf-${version}";
#   version = "0.1";
# 
#   installPhase = ''
#   	mkdir -p $out/bin
#   	cp ${rzf} $out/bin
#   '';
# 
#   meta = with pkgs.lib; {
#     description = ''
#       Fuzzy finder you can use locally, and in remote sessions.
#         e.g. `printf "hello\nworld" | rzfi`
#       	fzf-tmux is used when in tmux, rofi -dmenu is used outside of tmux
#     '';
#     platforms = platforms.all;
#   };
# 
# }
pkgs.writeShellApplication {
  name = "rzf";
  runtimeInputs = with pkgs; [ fzf rofi ];
  text = ''
    if [ "$TERM" == 'screen' ]; then
      fzf-tmux
    else
    	rofi -dmenu
    fi
  '';
}

