{ stdenv, lib, fetchzip, autoPatchelfHook }:

stdenv.mkDerivation rec {
  name = "pixel-vision-8-${version}";

  version = "1.0.0";

  src = fetchzip {
    url = "https://github.com/PixelVision8/PixelVision8/releases/download/v1.0.0/PixelVision8-v${version}-linux.zip";
    sha256 = "1xi56z9sn340gsz9vnfp15dyfcv33kq8b9pr235hyc8gzk750rwb";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  sourceRoot = ".";

  installPhase = ''
    find "PixelVision8-${version}-linux/" -type f -exec install -vDm 755 {} "$out/lib/{}" \;
  	ln -s "$out/lib/PixelVision8-v1.0.0-linux/Pixel Vision 8" "$out/bin/pv8"
  '';

  meta = with lib; {
    homepage = "https://pixelvision8.github.io/Website";
    description = "Pixel Vision 8 is a next generation 8-bit fantasy game console";
    license = licenses.mspl;
    platforms = platforms.all;
  };
}
