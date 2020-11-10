{ stdenv, requireFile, makeWrapper
, glib, xorg, zlib, freetype, fontconfig
} :
let
  version = "6.0.16";

in stdenv.mkDerivation {
  name = "gaussview-${version}";

  src = requireFile {
    name = "gv-6016-Linux-x86_64.tbz";
    sha256 = "0f4ngf3d2qz58g7qsqp9jwsmv0iv5n6s3cq8ld1kwxl1ikgsimjx";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/bin $out/data

    for dir in bin data help lib; do
      mkdir -p $out/$dir
      cp -r $dir/ $out
    done

    cp gv6.key $out
    cp gview.exe $out/bin
    cp qt.conf $out
    cp -r plugins $out/lib

    # Skip the ScJobManager

    # Use a custom script instead of gview.sh
    makeWrapper $out/bin/gview.exe $out/bin/gview \
      --set GV_DIR $out --set ALLOWINDIRECT 1 --set QT_PLUGIN_PATH $out/lib/plugins
  '';

  dontPatchELF = true;

  dontStrip = true;

  preFixup =
  let
    libPathEXE = stdenv.lib.makeLibraryPath [
      stdenv.cc.cc.lib
      glib.out
      xorg.libXext
      xorg.libX11
    ];
    libPathQt = stdenv.lib.makeLibraryPath [
      stdenv.cc.cc.lib
      freetype
      fontconfig
      glib.out
      xorg.libXext
      xorg.libXrender
      xorg.libICE
      xorg.libX11
      xorg.libSM
      zlib
    ];
  in ''
    # Fix the binary
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath $out/lib:$out/lib/MesaGL:${libPathEXE} $out/bin/gview.exe

    # Fix the libs
    for l in $(ls $out/lib/libQt*); do
        patchelf --set-rpath '$ORIGIN':$out/lib:${libPathQt} $l
    done

  '';

  meta = with stdenv.lib; {
    description = "GUI for the Gaussian quantum chemistry software package";
    homepage = http://gaussian.com/gaussian16/;
    license = licenses.unfree;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}

