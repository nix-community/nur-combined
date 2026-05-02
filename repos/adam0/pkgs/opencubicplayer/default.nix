{
  # keep-sorted start
  alsa-lib,
  autoconf-archive,
  autoreconfHook,
  bzip2,
  cjson,
  fetchFromGitHub,
  flac,
  freetype,
  game-music-emu,
  lib,
  libdiscid,
  libjpeg,
  libmad,
  libogg,
  libpng,
  libvorbis,
  makeWrapper,
  ncurses,
  perl,
  pkg-config,
  sdl3,
  stdenv,
  texinfo,
  unifont,
  unifont-csur,
  unifont_upper,
  util-linux,
  xa,
  zlib,
  # keep-sorted end
}: let
  ancient = stdenv.mkDerivation rec {
    pname = "libancient";
    version = "2.3.0";

    src = fetchFromGitHub {
      owner = "temisu";
      repo = "ancient";
      rev = "v${version}";
      hash = "sha256-raRKg4Gm4JFaTGbuBldCOGEAAAQjf92Ud99lyFa/u2w=";
    };

    nativeBuildInputs = [
      # keep-sorted start
      autoconf-archive
      autoreconfHook
      pkg-config
      # keep-sorted end
    ];

    meta = {
      description = "Decompression library for ancient formats";
      homepage = "https://github.com/temisu/ancient";
      license = lib.licenses.bsd2;
      platforms = lib.platforms.unix;
    };
  };
in
  stdenv.mkDerivation {
    pname = "opencubicplayer";
    version = "0-unstable-2026-05-02";

    src = fetchFromGitHub {
      owner = "mywave82";
      repo = "opencubicplayer";
      rev = "6d9ce3c785b5b68227883694de5e5bb6f3676765";
      fetchSubmodules = true;
      hash = "sha256-rlXsGYveAmZb/m06m8t+RtQRCS4Wav5sAFpZDJ/vVWc=";
    };

    nativeBuildInputs = [
      # keep-sorted start
      makeWrapper
      perl
      pkg-config
      texinfo
      util-linux
      xa
      # keep-sorted end
    ];

    buildInputs = [
      # keep-sorted start
      alsa-lib
      ancient
      bzip2
      cjson
      flac
      freetype
      game-music-emu
      libdiscid
      libjpeg
      libmad
      libogg
      libpng
      libvorbis
      ncurses
      sdl3
      unifont
      unifont-csur
      unifont_upper
      zlib
      # keep-sorted end
    ];

    postPatch = ''
      patchShebangs .
    '';

    configureFlags = [
      # keep-sorted start
      "--with-unifont-csur-ttf=${unifont-csur}/share/fonts/truetype/unifont_csur.ttf"
      "--with-unifont-otf=${unifont}/share/fonts/opentype/unifont.otf"
      "--with-unifont-upper-otf=${unifont_upper}/share/fonts/opentype/unifont_upper.otf"
      "--without-desktop_file_install"
      "--without-sdl"
      "--without-sdl2"
      "--without-unifont-csur-otf"
      "--without-update-desktop-database"
      "--without-update-mime-database"
      "--without-x11"
      # keep-sorted end
    ];

    enableParallelBuilding = true;

    postInstall = ''
      substituteInPlace "$out/share/ocp/etc/ocp.ini" \
        --replace-fail 'playerdevices=devpALSA devpOSS devpCA devpSDL2 devpSDL devpNone devpDisk' \
                       'playerdevices=devpSDL3 devpALSA devpOSS devpNone devpDisk'

      wrapProgram "$out/bin/ocp" \
        --add-flags "-spdevpSDL3 -dcurses" \
        --set-default SDL_AUDIODRIVER pipewire
    '';

    meta = {
      description = "Text-based module and retro music player";
      homepage = "https://github.com/mywave82/opencubicplayer";
      license = lib.licenses.gpl2Plus;
      mainProgram = "ocp";
      platforms = lib.platforms.linux;
    };
  }
