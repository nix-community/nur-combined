{ lib
, fetchFromGitHub
, stdenv
, makeDesktopItem
, openal
, pkgconfig
, libogg
, libvorbis
, SDL
, SDL_image
, makeWrapper
, zlib
, file
, libpng
, libjpeg_turbo
, client ? true
, server ? true
}:

with lib;

stdenv.mkDerivation rec {

  # if cliend crashes after start, try
  # echo "ati_mda_bug 1" >> ~/.config/assaultcube/config/autoexec.cfg

  # master branch has legacy (1.2.0.2) protocol 1201 and gcc 6 fix.
  pname = "assaultcube";
  version = "unstable-2020-21-08";

  src = fetchFromGitHub {
    owner = "assaultcube";
    repo = "AC";
    rev = "2f61ff92d3b28758a8467b9044f93d9bc7fa6dac";
    sha256 = "sha256-bVY4KoX2ZCz9czHxhMB6Sz4nGV/f8vjH9k+n2Gy2Nhk=";
  };

  # was useless before someone broke SDL_image, see https://github.com/NixOS/nixpkgs/pull/97919/
  NIX_LDFLAGS = "-lpng -ljpeg";

  nativeBuildInputs = [ makeWrapper pkgconfig ];

  buildInputs = [ file zlib ]
    ++ optionals client [ openal SDL SDL_image libogg libvorbis libjpeg_turbo libpng ];

  targets = (optionalString server "server") + (optionalString client " client");
  makeFlags = [ "-C source/src" "CXX=c++" targets ];

  desktop = makeDesktopItem {
    name = "AssaultCube";
    desktopName = "AssaultCube";
    comment = "A multiplayer, first-person shooter game, based on the CUBE engine. Fast, arcade gameplay.";
    genericName = "First-person shooter";
    categories = "Game;ActionGame;Shooter";
    icon = "assaultcube";
    exec = pname;
  };

  gamedatadir = "share/games/${pname}";

  installPhase = ''

    bindir=$out/bin

    mkdir -p $bindir $out/$gamedatadir

    cp -r config packages $out/$gamedatadir

    if (test -e source/src/ac_client) then
      cp source/src/ac_client $bindir
      mkdir -p $out/share/applications
      cp ${desktop}/share/applications/* $out/share/applications
      install -Dpm644 packages/misc/icon.png $out/share/icons/assaultcube.png
      install -Dpm644 packages/misc/icon.png $out/share/pixmaps/assaultcube.png

      makeWrapper $out/bin/ac_client $out/bin/${pname} \
        --run "cd $out/$gamedatadir" --add-flags "--home=\$HOME/.config/assaultcube/ --init"
    fi

    if (test -e source/src/ac_server) then
      cp source/src/ac_server $bindir
      makeWrapper $out/bin/ac_server $out/bin/${pname}-server \
        --run "cd $out/$gamedatadir" --add-flags "-Cconfig/servercmdline.txt"
    fi
  '';

  meta = {
    description = "Fast and fun first-person-shooter based on the Cube fps";
    homepage = "https://assault.cubers.net";
    maintainers = [ maintainers.genesis ];
    platforms = platforms.linux; # should work on darwin with a little effort.
    license = lib.licenses.free;
  };
}
