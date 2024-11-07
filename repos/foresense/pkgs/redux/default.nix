{
  lib,
  stdenv,
  libX11,
  libXext,
  alsa-lib,
  autoPatchelfHook,
  requireFile,
}:
stdenv.mkDerivation {
  pname = "redux";
  version = "1.3.5";

  src = requireFile {
    name = "rns_rdx_135_linux_x86_64.tar.gz";
    url = "https://www.renoise.com/products/redux";
    sha256 = "1kwqdlfcj26jy1szs4gkwdwd3gv3r11scj1nikban2k0063byr4c";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libX11
    libXext
    alsa-lib
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst/Redux
    cp -r ./renoise_redux_x86_64/* $out/lib/vst/Redux

    runHook postInstall
  '';

  meta = with lib; {
    description = "Sample-based instrument, with a powerful phrase sequencer";
    homepage = "https://www.renoise.com/products/redux";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfreeRedistributable;
    platforms = [ "x86_64-linux" ];
  };
}
