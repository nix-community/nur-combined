{ lib, writeShellScriptBin, callPackage, steam, mangohud, xdelta, libunwind, symlinkJoin
}:
let

  anime-game-launcher-unwrapped = callPackage ./unwrapped.nix { };

  fakePkExec = writeShellScriptBin "pkexec" ''
    declare -a final
    positional=""
    for value in "$@"; do
      if [[ -n "$positional" ]]; then
        final+=("$value")
      elif [[ "$value" == "-n" ]]; then
        :
      else
        positional="y"
        final+=("$value")
      fi
    done
    exec "''${final[@]}"
  '';

  steam-run-custom = (steam.override {
    extraPkgs = p: [ mangohud xdelta ];
    extraLibraries = p: [ libunwind ];
    extraProfile = ''
      export PATH=${fakePkExec}/bin:$PATH
    '';
  }).run;

  wrapper = writeShellScriptBin "anime-game-launcher" ''
    ${steam-run-custom}/bin/steam-run ${anime-game-launcher-unwrapped}/bin/anime-game-launcher
  '';
in
symlinkJoin {
  inherit (anime-game-launcher-unwrapped) pname version name;
  paths = [ wrapper ];

  meta = with lib; {
    description = "An Anime Game Launcher variant written on Rust, GTK4 and libadwaita, using Anime Game Core library";
    homepage = "https://gitlab.com/an-anime-team/an-anime-game-launcher-gtk/";
    license = licenses.gpl3Only;
  };
}
