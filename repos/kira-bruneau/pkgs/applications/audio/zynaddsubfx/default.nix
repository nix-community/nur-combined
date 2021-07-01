{ lib
, stdenv
, fetchFromGitHub
, callPackage

  # Required build tools
, cmake
, makeWrapper
, pkg-config

  # Required dependencies
, fftw
, liblo
, minixml
, zlib

  # Optional dependencies
, alsaSupport ? stdenv.hostPlatform.isLinux
, alsaLib
, dssiSupport ? false
, dssi
, ladspaH
, jackSupport ? true
, libjack2
, lashSupport ? false
, lash
, ossSupport ? true
, portaudioSupport ? true
, portaudio
, sndioSupport ? stdenv.hostPlatform.isOpenBSD
, sndio

  # Optional GUI dependencies
, guiModule ? "off"
, cairo
, fltk13
, libGL
, libjpeg
, libX11
, libXpm
, ntk

  # Test dependencies
, cxxtest
, ruby
}:

assert builtins.any (g: guiModule == g) [ "fltk" "ntk" "zest" "off" ];

let
  guiName = {
    "fltk" = "FLTK";
    "ntk" = "NTK";
    "zest" = "Zyn-Fusion";
  }.${guiModule};
  mruby-zest = callPackage ./mruby-zest { };
in stdenv.mkDerivation rec {
  pname = "zynaddsubfx";
  version = "3.0.6-rc3";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-eIj1S8aWpXREbKIoZyvxSCjM9RVc4OsIm/BFNsdoonE=";
  };

  outputs = [ "out" "doc" ];

  postPatch = ''
    patchShebangs .
    substituteInPlace src/Misc/Config.cpp --replace /usr $out
  '';

  nativeBuildInputs = [ cmake makeWrapper pkg-config ];

  buildInputs = [ fftw liblo minixml zlib ]
    ++ lib.optionals alsaSupport [ alsaLib ]
    ++ lib.optionals dssiSupport [ dssi ladspaH ]
    ++ lib.optionals jackSupport [ libjack2 ]
    ++ lib.optionals lashSupport [ lash ]
    ++ lib.optionals portaudioSupport [ portaudio ]
    ++ lib.optionals sndioSupport [ sndio ]
    ++ lib.optionals (guiModule == "fltk") [ fltk13 libjpeg libXpm ]
    ++ lib.optionals (guiModule == "ntk") [ ntk cairo libXpm ]
    ++ lib.optionals (guiModule == "zest") [ libGL libX11 ];

  cmakeFlags = [ "-DGuiModule=${guiModule}" ]
    # OSS library is included in glibc.
    # Must explicitly disable if support is not wanted.
    ++ lib.optional (!ossSupport) "-DOssEnable=OFF"
    # Find FLTK without requiring an OpenGL library in buildInputs
    ++ lib.optional (guiModule == "fltk") "-DFLTK_SKIP_OPENGL=ON";

  doCheck = true;
  checkInputs = [ cxxtest ruby ];

  # PortChecker test fails when lashSupport is enabled because
  # zynaddsubfx takes to long to start trying to connect to lash
  checkPhase = lib.optional lashSupport ''
    runHook preCheck
    ctest --force-new-ctest-process -E '^PortChecker$'
    runHook postCheck
  '';

  # Use Zyn-Fusion logo for zest build
  # Derived from https://raw.githubusercontent.com/mruby-zest/mruby-zest/ea4894620bf80ae59593b5d404b950d436a91e6c/example/ZynLogo.qml
  postInstall = lib.optional (guiModule == "zest") ''
    rm -r "$out/share/pixmaps"
    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    cp ${./ZynLogo.svg} "$out/share/icons/hicolor/scalable/apps/zynaddsubfx.svg"
  '';

  # When building with zest GUI, patch plugins
  # and standalone executable to properly locate zest
  postFixup = lib.optional (guiModule == "zest") ''
    for lib in "$out/lib/lv2/ZynAddSubFX.lv2/ZynAddSubFX_ui.so" "$out/lib/vst/ZynAddSubFX.so"; do
      patchelf --set-rpath "${mruby-zest}:$(patchelf --print-rpath "$lib")" "$lib"
    done

    wrapProgram "$out/bin/zynaddsubfx" \
      --prefix PATH : ${mruby-zest} \
      --prefix LD_LIBRARY_PATH : ${mruby-zest}
  '';

  meta = with lib; {
    description = "High quality software synthesizer (${guiName} GUI)";
    homepage =
      if guiModule == "zest"
      then "https://zynaddsubfx.sourceforge.io/zyn-fusion.html"
      else "https://zynaddsubfx.sourceforge.io";

    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ goibhniu kira-bruneau ];
    platforms = platforms.all;
    broken = stdenv.isDarwin;
  };
}
