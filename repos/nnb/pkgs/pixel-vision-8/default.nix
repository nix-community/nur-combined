{ stdenv, lib, fetchzip, autoPatchelfHook, zlib }:

stdenv.mkDerivation rec {
  name = "pixel-vision-8-${version}";
  version = "1.0.0";

  src = fetchzip {
    url = "https://github.com/PixelVision8/PixelVision8/releases/download/v${version}/PixelVision8-v${version}-linux.zip";
    sha256 = "19yjj7vycr7mdq2d82ivb6k3f7sn29lmrpj92xip99y5rsf05lfi";
    stripRoot = false;
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [ stdenv.cc.cc.lib zlib ];

  installPhase = ''
    find "PixelVision8-v${version}-linux" -type f -exec install -vDm 755 {} "$out/lib/pv8/{}" \;
    install -dm 755 "$out/bin"
  	ln -s "$out/lib/pv8/PixelVision8-v1.0.0-linux/Pixel Vision 8" "$out/bin/pv8"
  '';

  meta = with lib; {
    homepage = "https://pixelvision8.github.io/Website";
    description = "Pixel Vision 8 is a next generation 8-bit fantasy game console";
    license = licenses.mspl;
  };
}
