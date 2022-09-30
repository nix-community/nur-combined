{ stdenvNoCC
, lib
, fetchFromGitHub
, ...
} @ args:

stdenvNoCC.mkDerivation rec {
  pname = "san-francisco";
  version = "53ffbe571bb83dbb4835a010b4a49ebb9a32fc55";
  src = fetchFromGitHub ({
    owner = "xMuu";
    repo = "arch-kde-fontconfig";
    rev = "53ffbe571bb83dbb4835a010b4a49ebb9a32fc55";
    fetchSubmodules = false;
    sha256 = "MPrqqXwYX9Ij4h7jiOktTyxx52p17oVKt+ZowcH6deM=";
  });

  installPhase = ''
    mkdir -p $out/share/fonts/{opentype,truetype}/
    cp */*.otf $out/share/fonts/opentype/
    cp */*.ttc $out/share/fonts/truetype/
  '';
}
