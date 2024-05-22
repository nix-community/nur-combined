{
  stdenvNoCC,
  lib,
  p7zip,
  ...
}:
# Args
source:
stdenvNoCC.mkDerivation rec {
  inherit (source) pname version src;

  nativeBuildInputs = [ p7zip ];

  unpackPhase = ''
    7z -aoa x $src
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp *.ttf *.ttc $out/share/fonts/truetype/
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "${pname} font";
    homepage = "http://cheonhyeong.com/Simplified/download.html";
  };
}
