{pkgs, ...}:
let 
  systemdUserService = import <dotfiles/lib/systemdUserService.nix>;
  adskipper = pkgs.writeShellScriptBin "spotify-adskip" ''
    PLAYERCTL=${pkgs.playerctl}/bin/playerctl
    echo Executando...
    function handle {
        echo $1
        if [[ $1 =~ ^spotify:ad:.* ]]; then
            echo Pulando ad...
            $PLAYERCTL next -p spotify
        fi
    }
    $PLAYERCTL metadata -p spotify --format "{{mpris:trackid}}" -F 2> /dev/null \
    | while read line; do \
        handle $line; \
    done
    '';
  adskipperBinary = "${adskipper}/bin/spotify-adskip";
in systemdUserService {
  description = "Spotify ad skipper";
  command = adskipperBinary;
}
