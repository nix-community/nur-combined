{ pkgs, ... }:
with pkgs;
let
  name = "stremio";
  version = "4.4.137";
  serverJS = builtins.fetchurl {
    url = "https://s3-eu-west-1.amazonaws.com/stremio-artifacts/four/v${version}/server.js";
    sha256 = "sha256:127rfyraa59cx5r7nlvpnsclnkrylvahl3q7g4qz80sz670jywks";
  };
  src = fetchgit {
    url = "https://github.com/Stremio/stremio-shell";
    rev = "v" + version;
    sha256 = "sha256-EN5bHLeNJZjGc7IEsIjWvMv9KAcK0sjYkxH2mvwi7Dc=";
    fetchSubmodules = true;
  };
  pkg = qt5.mkDerivation rec {
    inherit version name src;

    nativeBuildInputs = [ which cmake ];
    buildInputs = [
      ffmpeg
      mpv
      nodejs
      openssl
      qt5.qtbase
      qt5.qtdeclarative
      qt5.qtquickcontrols
      qt5.qtquickcontrols2
      qt5.qttools
      qt5.qttranslations
      qt5.qtwebchannel
      qt5.qtwebengine
      librsvg
    ];

    dontWrapQtApps = true;
    postFixup = ''
      wrapQtApp "$out/opt/stremio/stremio" --prefix PATH : "$out/opt/stremio"
      cp ${serverJS} $out/opt/stremio/server.js
      mkdir $out/bin -p
      ln -s "$out/opt/stremio/stremio" "$out/bin/stremio"
      ln -s "$(which node)" "$out/opt/stremio/node"
    '';
  };
  stremioItem = makeDesktopItem {
    name = "Stremio";
    exec = "${pkg}/bin/stremio %U";
    icon = builtins.fetchurl {
      url = "https://www.stremio.com/website/stremio-logo-small.png";
      sha256 = "15zs8h7f8fsdkpxiqhx7wfw4aadw4a7y190v7kvay0yagsq239l6";
    };
    comment = "Torrent movies and TV series";
    desktopName = "Stremio";
    genericName = "Movies and TV Series";
  };
in
stremioItem
