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
    runHook preUnpack

    7z -aoa x $src

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype/
    cp *.ttf *.ttc $out/share/fonts/truetype/

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "${pname} font";
    homepage = "http://cheonhyeong.com/Simplified/download.html";
    license = lib.licenses.unfree;
  };
}
