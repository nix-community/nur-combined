{ stdenv
, sources
, lib
, autoPatchelfHook
, makeWrapper
, steam
  # Dependencies
, libadwaita
, gtk4
, gnome2
, cairo
, glib
, xz
, bzip2
, zlib
  # Runtime tools
, unzip
, gnutar
, git
, curl
, xdelta
, cabextract
, iputils
, ...
} @ args:

let
  steam-run = (steam.override {
    extraPkgs = p: [
      unzip
      gnutar
      git
      curl
      xdelta
      cabextract
      iputils
    ];
    runtimeOnly = true;
  }).run;

in
stdenv.mkDerivation rec {
  inherit (sources.an-anime-game-launcher-gtk-bin) pname version src;

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    libadwaita
    gtk4
    gnome2.pango
    cairo
    glib
    xz
    bzip2
    zlib
  ];

  installPhase = ''
    mkdir -p $out/bin $out/opt $out/share/applications $out/share/pixmaps
    install -m755 ${src} "$out/opt/an-anime-game-launcher-gtk"
    install -m644 ${./an-anime-game-launcher-gtk.desktop} "$out/share/applications/an-anime-game-launcher-gtk.desktop"
    install -m644 ${./icon.png} "$out/share/pixmaps/an-anime-game-launcher-gtk.png"

    substituteInPlace $out/share/applications/an-anime-game-launcher-gtk.desktop \
      --replace "Exec=AppRun" "Exec=$out/bin/an-anime-game-launcher-gtk"

    makeWrapper "${steam-run}/bin/steam-run" "$out/bin/an-anime-game-launcher-gtk" \
      --argv0 "an-anime-game-launcher-gtk" \
      --add-flags "$out/opt/an-anime-game-launcher-gtk"
  '';

  meta = with lib; {
    description = "(EXPERIMENTAL: Needs manual game patching) An Anime Game Launcher variant written on Rust, GTK4 and libadwaita, using Anime Game Core library";
    homepage = "https://github.com/an-anime-team/an-anime-game-launcher-gtk";
    license = licenses.gpl3;
  };
}
