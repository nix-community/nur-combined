{
  lib,
  stdenvNoCC,
  fetchurl,
  installFonts,
  unzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "plangothic";
  version = "2.9.5795";

  src = fetchurl {
    url = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project/releases/download/V${version}/Plangothic-Static-V${version}.zip";
    hash = "sha256-qm1H6T+hGbxQNBDTWiRUHRxNdAiGMvuaCC3c4nAwYYE=";
  };

  nativeBuildInputs = [
    installFonts
    unzip
  ];

  meta = {
    homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project";
    description = "CJK font based on Source Han Sans with glyphs for CJK Unified Ideographs Extension B–J";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
