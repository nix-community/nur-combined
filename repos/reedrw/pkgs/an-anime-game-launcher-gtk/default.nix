{ lib, rustPlatform, fetchFromGitLab
, pkg-config
, openssl
, glib
, pango
, gdk-pixbuf
, gtk4
, libadwaita
, blueprint-compiler
, gobject-introspection
, makeWrapper
, gsettings-desktop-schemas
, wrapGAppsHook4
, runtimeShell
, mangohud
, xdelta
, steam
, writeShellScriptBin
, callPackage
, libunwind
, librsvg
}:
let


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
in
rustPlatform.buildRustPackage rec {
  pname = "an-anime-game-launcher-gtk";
  version = "0.6.1";

  src = fetchFromGitLab {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = "67a34d9d4c0a66598e3be85f9aaa0ff95e6fc451";
    sha256 = "sha256-/NeGX0XvlRLV/HsP0WHUumd3ORjByKgxtfdAup2TfKU=";
    fetchSubmodules = true;
  };

  patches = [
    ./blp-compiler.patch
  ];

  cargoSha256 = "sha256-x2X/tZSpILvd9xj8t75VpvbuADq794J7zgV66oPddtw=";

  nativeBuildInputs = [
    pkg-config
    gtk4
    glib
    blueprint-compiler
    wrapGAppsHook4
    gobject-introspection
  ];

  buildInputs = [
    gdk-pixbuf
    openssl
    librsvg
    pango
    gsettings-desktop-schemas
    libadwaita
  ];

  postFixup = ''
    mv $out/bin/anime-game-launcher $out/bin/.anime-game-launcher-unwrapped
    makeWrapper ${steam-run-custom}/bin/steam-run $out/bin/anime-game-launcher \
      --add-flags $out/bin/.anime-game-launcher-unwrapped \
      "''${gappsWrapperArgs[@]}"
  '';

  dontWrapGApps = true;

  meta = with lib; {
    description = "An Anime Game Launcher variant written on Rust, GTK4 and libadwaita, using Anime Game Core library";
    homepage = "https://gitlab.com/an-anime-team/an-anime-game-launcher-gtk/";
    license = licenses.gpl3Only;
  };
}
