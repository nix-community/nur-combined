/*
nix-build -E 'with import <nixpkgs> { }; libsForQt5.callPackage ./aegisub.nix { }'
*/

# based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/video/aegisub/default.nix

/*

  version 3.2.2 crashes when loading video file

  $ aegisub

  libGL error: MESA-LOADER: failed to open i965: /nix/store/2mr45n3xcfsbvj6f9fl2s4v48chbhwy4-libdrm-2.4.109/lib/libdrm_nouveau.so.2: undefined symbol: drmCloseBufferHandle (search paths /run/opengl-driver/lib/dri, suffix _dri)
  libGL error: failed to load driver: i965
  libGL error: MESA-LOADER: failed to open i965: /nix/store/2mr45n3xcfsbvj6f9fl2s4v48chbhwy4-libdrm-2.4.109/lib/libdrm_nouveau.so.2: undefined symbol: drmCloseBufferHandle (search paths /run/opengl-driver/lib/dri, suffix _dri)
  libGL error: failed to load driver: i965
  libGL error: MESA-LOADER: failed to open swrast: /nix/store/2mr45n3xcfsbvj6f9fl2s4v48chbhwy4-libdrm-2.4.109/lib/libdrm_nouveau.so.2: undefined symbol: drmCloseBufferHandle (search paths /run/opengl-driver/lib/dri, suffix _dri)
  libGL error: failed to load driver: swrast

  [ load video file ]

  ./src/unix/glx11.cpp(498): assert ""tempContext"" failed in wxGLContext(): glXCreateContext failed
  The program 'aegisub' received an X Window System error.
  This probably reflects a bug in the program.
  The error was 'BadValue (integer parameter out of range for operation)'.
    (Details: serial 43407 error_code 2 request_code 153 minor_code 3)
    (Note to programmers: normally, X errors are reported asynchronously;
    that is, you will receive the error a while after causing it.
    To debug your program, run it with the --sync command line
    option to change this behavior. You can then get a meaningful
    backtrace from your debugger if you break on the gdk_x_error() function.)

*/

{ lib
, config
, stdenv
, fetchFromGitHub
, fetchurl
, fetchpatch
, boost
, boost17x
, ffmpeg
, ffms
, fftw
, fftwFloat
, fontconfig
, freetype
, icu
, autoreconfHook
, cmake
, ninja
, meson
, intltool
, libGL
, libGLU
, libX11
, libass
, pkg-config
, wxGTK31
, wxGTK28
, qt5
, wrapQtAppsHook
, zlib
, libiconv
, readline
, python3
, symlinkJoin

, spellcheckSupport ? true
, hunspell ? null

, automationSupport ? true
, lua ? null

, openalSupport ? false
, openal ? null

, alsaSupport ? stdenv.isLinux
, alsa-lib ? null

, pulseaudioSupport ? config.pulseaudio or stdenv.isLinux
, libpulseaudio ? null

, portaudioSupport ? false
, portaudio ? null
}:

assert spellcheckSupport -> (hunspell != null);
assert automationSupport -> (lua != null);
assert openalSupport -> (openal != null);
assert alsaSupport -> (alsa-lib != null);
assert pulseaudioSupport -> (libpulseaudio != null);
assert portaudioSupport -> (portaudio != null);

let
  inherit (lib) optional;

  boost_m4 = stdenv.mkDerivation {
    pname = "boost.m4";
    version = "aef755a";
    # https://github.com/tsuna/boost.m4
    src = fetchurl {
      url = "https://github.com/tsuna/boost.m4/raw/aef755a5c2788fb9011de16b38ebbbefc5b68f08/build-aux/boost.m4";
      sha256 = "Pwptckfgoc5vvKv4IdIfXj+DwbOmY/wCYtoslELWjhg=";
    };
    dontUnpack = true;
    installPhase = ''
      cp $src $out
    '';
  };

  luajit_lua51 = stdenv.mkDerivation rec {
    pname = "luajit";
    version = "2.1.0.20220127";
    src = fetchFromGitHub {
      # https://github.com/zhaozg/luajit-cmake
      owner = "zhaozg";
      repo = "luajit-cmake";
      rev = "9fcb5093e97b6ba37f7e9d0748c6a24a2bd28a2d";
      sha256 = "3SVxJQbW3M+GFdSVe6p6PWzRzjfFyPMjY6JpR3gC99k=";
    };
    luajitSrc = fetchFromGitHub {
      # https://github.com/LuaJIT/LuaJIT
      owner = "LuaJIT";
      repo = "LuaJIT";
      rev = "1d7b5029c5ba36870d25c67524034d452b761d27";
      sha256 = "K1XzW0lnQZrY164J+iUq7CZarttksQwiM7jv0KaBni4=";
    };
    nativeBuildInputs = [ cmake ];
    # need write access to luajitSrc
    postUnpack = ''
      cp -r ${luajitSrc} $sourceRoot/luajit
      chmod -R +w $sourceRoot/luajit
    '';
    cmakeFlags = [
      "-DLUAJIT_DIR=/build/source/luajit" # must be absolute path
    ];
  };


  luajit_lua52 = stdenv.mkDerivation rec {
    # luajit "compiled in lua-5.2 mode"
    # https://github.com/LuaJIT/LuaJIT/blob/1d7b5029c5ba36870d25c67524034d452b761d27/src/luaconf.h#L39
    # #define LUA_LUADIR	"/lua/5.1/"
    pname = "luajit";
    version = "2.1.0";
    src = ./src/luajit-lua52;
    /*
    src = fetchFromGitHub {
      # https://github.com/milahu/luajit-lua52
      # TODO install *.a *.so and exe files
      owner = "milahu";
      repo = "luajit-lua52";
      rev = "70cfa7ad9a8c207bb766cef5eb283e06b9547bd8";
      sha256 = "DRzkvsqkKn7sV9dioPQLoll9O6RpQOkUDDJS6Jf1AKw=";
      fetchSubmodules = true;
    };
    */
    /*
    src = fetchFromGitHub {
      # https://github.com/LuaJIT/LuaJIT
      # https://github.com/milahu/luajit-lua52
      owner = "LuaJIT";
      repo = "LuaJIT";
      rev = "1d7b5029c5ba36870d25c67524034d452b761d27";
      sha256 = "K1XzW0lnQZrY164J+iUq7CZarttksQwiM7jv0KaBni4=";
    };
    srcMeson = fetchFromGitHub {
      # https://github.com/Aegisub/Aegisub
      # https://github.com/TypesettingTools/Aegisub
      owner = "TypesettingTools";
      repo = "Aegisub";
      rev = "f21d8a36073acecad56b2621219ba82fedc04e37";
      sha256 = "gF3uomZKZPEiM4LynU/0RFpGUa3NuZRAuXBDN+AMLS4=";
    } + "/subprojects/packagefiles/luajit";
    */
    nativeBuildInputs = [
      meson
      ninja
    ];
    buildInputs = [ readline ];
    postUnpack = ''
      (
        cd $sourceRoot
        ./postunpack.sh
      )    
      sourceRoot=$sourceRoot/luajit
    '';
  };

  _boost = boost17x;
  boost = symlinkJoin { # needed for BOOST_ROOT
    name = "${_boost.name}-out-dev";
    paths = [ _boost.out _boost.dev ];
  };

  wxGTK = wxGTK31;
in

stdenv.mkDerivation rec {
  pname = "aegisub";
  version = "unstable-2022-06-08";

  src = fetchFromGitHub {
    owner = "TypesettingTools";
    repo = "Aegisub";
    rev = "4776ca9dd108f65003e55a03ef60e0dd50cae7f1";
    sha256 = "sha256-KTKKzP80nON7P6JFeYxugbwX03c3muZQQrjBClQnjYE=";
  };

  #src = ./src/Aegisub;

  patches = [
    #./fix-configure-find-boost-on-nix.patch
    # https://github.com/TypesettingTools/Aegisub/pull/157
    #./fix-configure-dont-find-library-iconv-on-linux.patch
    #./update-to-meson-version-0.58.0.patch
    # fix: ERROR: Automatic wrap-based subproject downloading is disabled
    ./disable-tests.patch
  ];

  # https://github.com/TypesettingTools/Aegisub/issues/151
  # https://github.com/mesonbuild/meson/issues/8801
  BOOST_ROOT = boost;

  mesonFlags = [
    "-Dportaudio=disabled"
    "-Dopenal=disabled"
    "-Duchardet=disabled"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    wrapQtAppsHook
  ];
  buildInputs = [
    #luajit_lua52
    #luajit_lua51 # Message: System luajit found but not compiled in 5.2 mode
    #luajit_2_1 # Run-time dependency luajit found: YES 2.1.0-beta3
    #luajit_2_0
    boost
    ffmpeg
    ffms
    # yes, we need both fftw
    fftw
    fftwFloat
    # FIXME -- Could NOT find uchardet (missing: uchardet_LIBRARIES uchardet_INCLUDE_DIRS)
    fontconfig
    freetype
    icu
    libGL
    #qt5.qtbase
    libGLU
    libX11
    libass
    libiconv # only needed for non-linux: darwin, windows?
    wxGTK
    # FIXME error: attribute 'gtk' missing
    wxGTK.gtk
    qt5.qtbase
    zlib
    python3 # src/Aegisub/tools/respack.py
  ]
  ++ optional alsaSupport alsa-lib
  #++ optional automationSupport lua
  ++ optional automationSupport luajit_lua52
  ++ optional openalSupport openal
  ++ optional portaudioSupport portaudio
  ++ optional pulseaudioSupport libpulseaudio
  ++ optional spellcheckSupport hunspell
  ;

  postUnpack = ''
    patchShebangs $sourceRoot/tools

    # fix: version.sh: line 28: git: not found
    mkdir $sourceRoot/build || true
    cat >$sourceRoot/build/git_version.h <<EOF
    #define BUILD_GIT_VERSION_NUMBER ${git_revision}
    #define BUILD_GIT_VERSION_STRING "${git_version_str}"
    #define TAGGED_RELEASE ${tagged_release}
    #define INSTALLER_VERSION "${installer_version}"
    #define RESOURCE_BASE_VERSION ${resource_version}"
    EOF
    echo >$sourceRoot/tools/version.sh
  '';

  enableParallelBuilding = true;

  hardeningDisable = [
    "bindnow"
    "relro"
  ];

  # TODO remove?
  # https://github.com/Aegisub/Aegisub/blob/master/build/version.sh
  git_revision = "0";
  git_version_str = "0000000";
  tagged_release = "0";
  installer_version = "0.0.0";
  resource_version = "0, 0, 0";

  # compat with icu61+
  # https://github.com/unicode-org/icu/blob/release-64-2/icu4c/readme.html#L554
  CXXFLAGS = [ "-DU_USING_ICU_NAMESPACE=1" ];

  # this is fixed upstream though not yet in an officially released version,
  # should be fine remove on next release (if one ever happens)
  NIX_LDFLAGS = "-lpthread";

  meta = with lib; {
    homepage = "https://github.com/Aegisub/Aegisub";
    description = "An advanced subtitle editor";
    longDescription = ''
      Aegisub is a free, cross-platform open source tool for creating and
      modifying subtitles. Aegisub makes it quick and easy to time subtitles to
      audio, and features many powerful tools for styling them, including a
      built-in real-time video preview.
    '';
    # The Aegisub sources are itself BSD/ISC, but they are linked against GPL'd
    # softwares - so the resulting program will be GPL
    license = licenses.bsd3;
    maintainers = [ maintainers.AndersonTorres ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}
