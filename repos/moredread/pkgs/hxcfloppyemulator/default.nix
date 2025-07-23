{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, fltk14
, libjpeg
, libpng
, xorg
, zlib
}:

stdenv.mkDerivation rec {
  pname = "hxcfloppyemulator";
  version = "unstable-2025-01-22";

  src = fetchFromGitHub {
    owner = "jfdelnero";
    repo = "HxCFloppyEmulator";
    rev = "0ae0cb26a4c8f18a16b1dddbde9135bb5b45a83b";
    sha256 = "sha256-EOrJJjjfVXG5Axo2a0yGHyvErLwOqegZzd45+CFLf14=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fltk14
    libjpeg
    libpng
    xorg.libX11
    xorg.libXext
    xorg.libXft
    xorg.libXinerama
    zlib
  ];

  postPatch = ''
    # Replace bundled FLTK paths with system FLTK
    substituteInPlace HxCFloppyEmulator_software/build/Makefile \
      --replace-fail '-I $(BASEDIR)/thirdpartylibs/fltk/fltk-1.x.x/' '$(shell ${fltk14}/bin/fltk-config --cxxflags --use-images --use-cairo)' \
      --replace-fail '$(shell $(BASEDIR)/thirdpartylibs/fltk/fltk-1.x.x/fltk-config --ldflags)' '$(shell ${fltk14}/bin/fltk-config --ldflags --use-images --use-cairo)' \
      --replace-fail 'FLTKLIB = $(BASEDIR)/thirdpartylibs/fltk/fltk-1.x.x/lib/libfltk.a $(BASEDIR)/thirdpartylibs/fltk/fltk-1.x.x/lib/libfltk_images.a' 'FLTKLIB = $(shell ${fltk14}/bin/fltk-config --libs --use-images --use-cairo)' \
      --replace-fail '$(MAKE) fltk' '# Skip bundled FLTK build'
  '';

  preBuild = ''
    cd build
  '';

  installPhase = ''
    runHook preInstall

    # Install binaries
    install -Dm755 hxcfloppyemulator $out/bin/hxcfloppyemulator
    install -Dm755 hxcfe $out/bin/hxcfe

    # Install libraries
    install -Dm755 libhxcfe.so $out/lib/libhxcfe.so
    install -Dm755 libusbhxcfe.so $out/lib/libusbhxcfe.so
    install -Dm644 libhxcadaptor.a $out/lib/libhxcadaptor.a

    runHook postInstall
  '';

  meta = with lib; {
    description = "HxC Floppy Emulator toolkit - GUI and command-line tools for floppy disk image manipulation";
    longDescription = ''
      The HxC Floppy Emulator toolkit provides tools to import, convert, analyze,
      and manipulate floppy disk images. It supports many formats and includes both
      a GUI application (hxcfloppyemulator) and command-line tool (hxcfe).
    '';
    homepage = "https://github.com/jfdelnero/HxCFloppyEmulator";
    license = licenses.gpl3;
    platforms = platforms.linux;
    mainProgram = "hxcfloppyemulator";
  };
}
