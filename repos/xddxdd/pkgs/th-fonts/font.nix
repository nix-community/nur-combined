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
    url = "http://cheonhyeong.com/File/${filename}.7z";
    inherit sha256;
  };

  nativeBuildInputs = [ p7zip ];

  unpackPhase = ''
    7z -aoa x ${src}
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/opentype/
    cp *.ttf *.ttc $out/share/fonts/opentype/
  '';

  meta = with lib; {
    description = "${pname} font";
    homepage = "http://cheonhyeong.com/Simplified/download.html";
  };
}
