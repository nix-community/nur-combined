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
  version = "unstable-2026-10-19";

  src = fetchFromGitHub {
    owner = "jfdelnero";
    repo = "HxCFloppyEmulator";
    rev = "030d0ec5f8ee3c815a700809a55d7523f8d2c88c";
    sha256 = "sha256-kGGQLTPw5pnIeIAqyMgiJxUAjPpRqDVFDSJKGijdffM=";
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
      --replace-fail 'FLTKLIBS = $(FLTKLIB) $(BASEDIR)/thirdpartylibs/fltk/fltk-1.x.x/lib/libfltk_images.a' 'FLTKLIBS = $(shell ${fltk14}/bin/fltk-config --libs --use-images --use-cairo)' \
      --replace-fail '$(MAKE) $(FLTKLIB)' '# Skip bundled FLTK build'
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
