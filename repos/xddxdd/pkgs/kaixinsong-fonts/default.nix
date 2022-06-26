{ stdenvNoCC
, lib
, fetchurl
, ...
} @ args:

let
  kaixinsong-a = fetchurl {
    url = "https://backblaze.lantian.pub/KaiXinSongA.ttf";
    sha256 = "sha256-ThHI0V3O9k5bVVSOV2RELRsfO+b8UjRvEzivm0jPGb0=";
  };
  kaixinsong-b = fetchurl {
    url = "https://backblaze.lantian.pub/KaiXinSongB.ttf";
    sha256 = "sha256-2nvseKgZSVIy0oYkT+DB+V0UfoSBG4Ds4EcWnFfNSkU=";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "kaixinsong-fonts";
  version = "3.0";

  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp ${kaixinsong-a} $out/share/fonts/truetype/KaiXinSongA.ttf
    cp ${kaixinsong-b} $out/share/fonts/truetype/KaiXinSongB.ttf
  '';

  meta = with lib; {
    description = "KaiXinSong";
    homepage = "http://www.guoxuedashi.net/zidian/bujian/KaiXinSong.php";
  };
}
