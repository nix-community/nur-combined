{
  lib,
  stdenv,
  libX11,
  libXext,
  libXcursor,
  libXrandr,
  libjack2,
  alsa-lib,
  mpg123,
  requireFile,
}:
stdenv.mkDerivation rec {
  pname = "renoise";
  version = "3.4.4";

  src = requireFile {
    name = "rns_344_linux_x86_64.tar.gz";
    url = "https://www.renoise.com/products/renoise";
    hash = "sha256-0D1lqkEE19q/BgN4PWukYqFoLljw7okHOzd/x+FQtzk=";
  };

  buildInputs = [
    alsa-lib
    libjack2
    libX11
    libXcursor
    libXext
    libXrandr
  ];

  installPhase = ''
    mkdir -p $out/{lib,bin,share/applications}
    mkdir -p $out/share/icons/hicolor/{48x48,64x64,128x128}/apps

    cp renoise $out/renoise
    ln -s $out/renoise $out/bin/renoise
    cp -r Resources $out
    cp -r Installer/renoise.desktop $out/share/applications/renoise.desktop
    cp Installer/renoise-48.png $out/share/icons/hicolor/48x48/apps/renoise.png
    cp Installer/renoise-64.png $out/share/icons/hicolor/64x64/apps/renoise.png
    cp Installer/renoise-128.png $out/share/icons/hicolor/128x128/apps/renoise.png

    for path in ${toString buildInputs}; do
      ln -s $path/lib/*.so* $out/lib/
    done
    ln -s ${stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/
  '';

  postFixup = ''
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) --set-rpath ${mpg123}/lib:$out/lib $out/renoise
    for path in $out/audiopluginserver*; do
      patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) --set-rpath $out/lib $path
    done
    substituteInPlace $out/share/applications/renoise.desktop --replace Exec=renoise Exec=$out/bin/renoise
  '';

  meta = {
    description = "Modern tracker-based DAW";
    homepage = "https://www.renoise.com/";
    mainProgram = "Renoise";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
}
