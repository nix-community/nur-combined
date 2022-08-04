{ lib
, callPackage
, libunwind
, mangohud
, steam
, symlinkJoin
, writeShellScriptBin
, xdelta
, runtimeShell
}:
let

  anime-game-launcher-unwrapped = callPackage ./unwrapped.nix { };

  fakePkExec = writeShellScriptBin "pkexec" ''
    declare -a final
    for value in "$@"; do
      final+=("$value")
    done
    exec "''${final[@]}"
  '';

  # Nasty hack for mangohud
  fakeBash = writeShellScriptBin "bash" ''
    declare -a final
    for value in "$@"; do
      final+=("$value")
    done
    if [[ "$MANGOHUD" == "1" ]]; then
      exec mangohud ${runtimeShell} "''${final[@]}"
    fi
    exec ${runtimeShell} "''${final[@]}"
  '';

  steam-run-custom = (steam.override {
    extraPkgs = p: [ mangohud xdelta ];
    extraLibraries = p: [ libunwind ];
    extraProfile = ''
      export PATH=${fakePkExec}/bin:${fakeBash}/bin:$PATH
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
