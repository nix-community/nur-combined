{
  # keep-sorted start
  alsa-lib,
  autoconf-archive,
  autoreconfHook,
  buildPackages,
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
  libopus,
  libpng,
  libvorbis,
  makeWrapper,
  ncurses,
  perl,
  pkg-config,
  sdl3,
  speex,
  stdenv,
  texinfo,
  unifont,
  unifont_upper ? null,
  util-linux,
  wavpack,
  xa,
  zlib,
  # keep-sorted end
}: let
  inherit
    (lib)
    # keep-sorted start
    escapeShellArgs
    optionalString
    optionals
    # keep-sorted end
    ;

  withSDL3 = builtins.elem stdenv.hostPlatform.system [
    # keep-sorted start
    "aarch64-linux"
    "i686-linux"
    "riscv64-linux"
    "x86_64-linux"
    # keep-sorted end
  ];

  audioDevice =
    if withSDL3
    then "devpSDL3"
    else "devpALSA";

  # Unifont moved its OTF variants into a subdirectory in 17.0.05, and nixpkgs
  # ships unifont_upper separately in older releases.
  unifontRoots = [unifont] ++ optionals (unifont_upper != null) [unifont_upper];

  wrapperArgs =
    [
      "--add-flags"
      "-sp${audioDevice} -dcurses"
    ]
    ++ optionals withSDL3 [
      "--set-default"
      "SDL_AUDIODRIVER"
      "pipewire"
    ];

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

    meta = with lib; {
      description = "Decompression library for ancient formats";
      homepage = "https://github.com/temisu/ancient";
      license = licenses.bsd2;
      platforms = platforms.unix;
    };
  };
in
  stdenv.mkDerivation rec {
    pname = "opencubicplayer";
    version = "3.5.0";

    src = fetchFromGitHub {
      owner = "mywave82";
      repo = "opencubicplayer";
      rev = "v${version}";
      fetchSubmodules = true;
      hash = "sha256-9LY4yIWdzfy6eHBX0Jkv2814+BBwzGVvY/cZwdV3naA=";
    };

    strictDeps = true;

    depsBuildBuild = [
      # keep-sorted start
      buildPackages.stdenv.cc
      buildPackages.zlib
      # keep-sorted end
    ];

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

    buildInputs =
      [
        # keep-sorted start
        alsa-lib
        ancient
        bzip2
        cjson
        flac
        game-music-emu
        libdiscid
        libjpeg
        libmad
        libogg
        libopus
        libpng
        libvorbis
        ncurses
        speex
        wavpack
        zlib
        # keep-sorted end
      ]
      ++ optionals withSDL3
      [
        # keep-sorted start
        freetype
        sdl3
        unifont
        # keep-sorted end
      ]
      ++ optionals (withSDL3 && unifont_upper != null) [unifont_upper];

    postPatch = ''
      patchShebangs .

      # Fixes the bundled AdPlug int32 type on non-x86 LP64 systems.
      substituteInPlace playopl/adplug-git/src/composer.h \
        --replace-fail $'#ifdef __x86_64__\n    typedef signed   int      int32;\n#else\n    typedef signed long int   int32;\n#endif' \
                         'typedef int32_t int32;'
    '';

    # Upstream requires unifont.otf and unifont_upper.otf, and treats CSUR as optional.
    preConfigure = optionalString withSDL3 ''
      unifontRoots=(${escapeShellArgs unifontRoots})

      findFont() {
        for root in "''${unifontRoots[@]}"; do
          found=$(find "$root/share/fonts" -name "$1" -print -quit)
          if [ -n "$found" ]; then
            printf '%s\n' "$found"
            return 0
          fi
        done
        return 1
      }

      unifontOtf=$(findFont unifont.otf) || {
        echo "unable to locate unifont.otf" >&2
        exit 1
      }
      configureFlagsArray+=("--with-unifont-otf=$unifontOtf")

      upperOtf=$(findFont unifont_upper.otf) || {
        echo "unable to locate unifont_upper.otf" >&2
        exit 1
      }
      configureFlagsArray+=("--with-unifont-upper-otf=$upperOtf")

      if csurOtf=$(findFont unifont_csur.otf); then
        configureFlagsArray+=("--with-unifont-csur-otf=$csurOtf")
      else
        configureFlagsArray+=(--without-unifont-csur-otf --without-unifont-csur-ttf)
      fi
    '';

    configureFlags =
      [
        # keep-sorted start
        "--with-alsa"
        "--with-flac"
        "--with-libgme"
        "--with-mad"
        "--with-opus"
        "--with-speex"
        "--with-wavpack"
        "--without-desktop_file_install"
        "--without-sdl"
        "--without-sdl2"
        "--without-update-desktop-database"
        "--without-update-mime-database"
        "--without-x11"
        # keep-sorted end
      ]
      ++ optionals withSDL3 ["--with-sdl3"]
      ++ optionals (!withSDL3) ["--without-sdl3"];

    enableParallelBuilding = true;

    doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

    checkPhase = ''
      runHook preCheck
      make -C dev test
      make -C stuff compat-test utf-16-test
      ./stuff/compat-test
      ./stuff/utf-16-test
      runHook postCheck
    '';

    postInstall = ''
      substituteInPlace "$out/share/ocp/etc/ocp.ini" \
        --replace-fail 'playerdevices=devpALSA devpOSS devpCA devpSDL2 devpSDL devpNone devpDisk' \
                       'playerdevices=${optionalString withSDL3 "devpSDL3 "}devpALSA devpOSS devpNone devpDisk'

      wrapProgram "$out/bin/ocp" ${escapeShellArgs wrapperArgs}
    '';

    meta = with lib; {
      description = "Text-based module and retro music player";
      homepage = "https://github.com/mywave82/opencubicplayer";
      license = licenses.gpl2Plus;
      mainProgram = "ocp";
      platforms = platforms.linux;
    };
  }
