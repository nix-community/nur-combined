{ stdenvNoCC, fetchzip }: let
  version = "5.414.0";
in stdenvNoCC.mkDerivation {
  pname = "nvflash";
  inherit version;

  src = fetchzip {
    # https://www.techpowerup.com/download/nvidia-nvflash/
    url = "http://us1-dl.techpowerup.com/files/?/nvflash_${version}_linux.zip";
    sha256 = "0znglxarhldk774cmja623nlp65vnz703jlms2fj194l00shplsb";
  };

  buildPhase = "true";

  installPhase = ''
    install -Dm0755 nvflash_linux $out/bin/nvflash
  '';

  meta.broken = true;
}
