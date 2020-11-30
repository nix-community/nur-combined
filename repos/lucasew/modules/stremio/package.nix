{pkgs, ...}:
with pkgs;
let
  serverJS = builtins.fetchurl {
    url = "https://s3-eu-west-1.amazonaws.com/stremio-artifacts/four/master/server.js";
    sha256 = "01in2fq1jv9a6brcz1bbwc41c5qmdr2k61rizb7fcg4v8r2dvqb5";
  };
  pkg = qt5.mkDerivation rec {
    name = "stremio";
    version = "4.4.116";

    nativeBuildInputs = [ which ];
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
    preFixup = ''
      wrapQtApp "$out/opt/stremio/stremio" --prefix PATH : "$out/opt/stremio"
    '';

    src = fetchgit {
      url = "https://github.com/Stremio/stremio-shell";
      rev = "v" + version;
      sha256 = "0v1mk4d2adx27m0z78j3vxnwx4pd2q6dnd9mqkz2prq6gpirhh7a";
      fetchSubmodules = true;
    };

    buildPhase = ''
      cp ${serverJS} server.js
      make -f release.makefile PREFIX="$out/"
    '';

    installPhase = ''
      make -f release.makefile install PREFIX="$out/"
      mkdir -p "$out/bin"
      ln -s "$out/opt/stremio/stremio" "$out/bin/stremio"
      # mkdir -p "$out/share/applications"
      # ln -s "$out/opt/stremio/smartcode-stremio.desktop" "$out/share/applications"
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
in stremioItem
