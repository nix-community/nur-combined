{ stdenvNoCC
, lib
, fetchurl
, p7zip
  # Args
, pname
, version
, filename ? "${pname}-${version}"
, sha256
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  inherit pname version;
  src = fetchurl {
    url = "https://backblaze.lantian.pub/${filename}.7z";
    inherit sha256;
  };

  nativeBuildInputs = [ p7zip ];

  unpackPhase = ''
    7z -aoa x ${src}
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp *.ttf *.ttc $out/share/fonts/truetype/
  '';

  meta = with lib; {
    description = "${pname} font";
    homepage = "http://cheonhyeong.com/Simplified/download.html";
  };
}
