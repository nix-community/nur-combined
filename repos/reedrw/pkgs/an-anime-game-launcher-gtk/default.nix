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
  version = "1.0.0-rc1";

  src = fetchFromGitLab {
    owner = "an-anime-team";
    repo = "an-anime-game-launcher-gtk";
    rev = "bcdb0217ade88eb9ac226d76a884f041ae11049d";
    sha256 = "sha256-vSnt1UDdH/5L+9we5fgj2thtb9qx0zZe2voK0SFvqFA=";
    fetchSubmodules = true;
  };

  patches = [
    ./blp-compiler.patch
  ];

  cargoSha256 = "sha256-3YxwKWBduF3B0fKOhC+RqGgE+SldoqGuMMw/TassTNs=";

  nativeBuildInputs = [
    pkg-config
    gtk4
    glib
    blueprint-compiler
    wrapGAppsHook4
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
