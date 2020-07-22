{ stdenv
, lib
, fetchFromGitHub
, callPackage

  # Required build tools
, cmake
, pkgconfig

  # Required dependencies
, fftw
, liblo
, minixml
, zlib

  # Optional dependencies
, alsaSupport ? true
, alsaLib ? null
, dssiSupport ? false
, dssi ? null
, ladspaH ? null
, jackSupport ? true
, libjack2 ? null
, lashSupport ? false
, lash ? null
, ossSupport ? true
, portaudioSupport ? true
, portaudio ? null

  # Optional GUI dependencies
, guiModule ? "off"
, cairo ? null
, fltk13 ? null
, libGL ? null
, libjpeg ? null
, libX11 ? null
, libXpm ? null
, ntk ? null

  # Test dependencies
, cxxtest
}:

assert alsaSupport -> alsaLib != null;
assert dssiSupport -> dssi != null && ladspaH != null;
assert jackSupport -> libjack2 != null;
assert lashSupport -> lash != null;
assert portaudioSupport -> portaudio != null;

assert builtins.any (g: guiModule == g) [ "fltk" "ntk" "zest" "off" ];
assert guiModule == "fltk" -> fltk13 != null && libjpeg != null && libXpm != null;
assert guiModule == "ntk" -> ntk != null && cairo != null && libXpm != null;
assert guiModule == "zest" -> libGL != null && libX11 != null;

stdenv.mkDerivation rec {
  pname = "zynaddsubfx";
  version = "3.0.5";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    sha256 = "1vh1gszgjxwn8m32rk5222z1j2cnjax0bqpag7b47v6i36p2q4x8";
    fetchSubmodules = true;
  };

  patchPhase = ''
    substituteInPlace src/Misc/Config.cpp --replace /usr $out
  '';

  nativeBuildInputs = [ cmake pkgconfig ];
  buildInputs = [ fftw liblo minixml zlib ]
    ++ lib.optional alsaSupport alsaLib
    ++ lib.optionals dssiSupport [ dssi ladspaH ]
    ++ lib.optional jackSupport libjack2
    ++ lib.optional lashSupport lash
    ++ lib.optional portaudioSupport portaudio
    ++ lib.optionals (guiModule == "fltk") [ fltk13 libjpeg libXpm ]
    ++ lib.optionals (guiModule == "ntk") [ ntk cairo libXpm ]
    ++ lib.optionals (guiModule == "zest") [ libGL libX11 ];

  cmakeFlags = [ "-DGuiModule=${guiModule}" ]
    # OSS library is included in glibc.
    # Must explicitly disable if support is not wanted.
    ++ lib.optional (!ossSupport) "-DOssEnable=OFF"

    # Find FLTK without requiring an OpenGL library in buildInputs
    ++ lib.optional (guiModule == "fltk") "-DFLTK_SKIP_OPENGL=ON"

    # ZynFusionDir is considered a "developer only" option, but mruby-zest
    # doesn't follow the FHS and this is the simplest way to depend on it.
    ++ lib.optional (guiModule == "zest") [
    "-DZynFusionDir=${callPackage ./mruby-zest.nix { }}"
  ];

  doCheck = true;
  checkInputs = [ cxxtest ];

  meta = with lib; {
    description = "High quality software synthesizer";
    homepage = "https://zynaddsubfx.sourceforge.io";
    license = licenses.gpl2;
    maintainers = with maintainers; [ goibhniu metadark nico202 ];
    platforms = platforms.linux;
  };
}
