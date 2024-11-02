{
  stdenvNoCC,
  lib,
  fetchurl,
}:
let
  kaixinsong-a = fetchurl {
    url = "https://backblaze.lantian.pub/KaiXinSongA.ttf";
    hash = "sha256-ThHI0V3O9k5bVVSOV2RELRsfO+b8UjRvEzivm0jPGb0=";
  };
  kaixinsong-b = fetchurl {
    url = "https://backblaze.lantian.pub/KaiXinSongB.ttf";
    hash = "sha256-2nvseKgZSVIy0oYkT+DB+V0UfoSBG4Ds4EcWnFfNSkU=";
  };
in
stdenvNoCC.mkDerivation rec {
  pname = "kaixinsong-fonts";
  version = "3.0";

  dontUnpack = true;
  postInstall = ''
    mkdir -p $out/share/fonts/truetype/
    install -m644 \
      ${kaixinsong-a} \
      ${kaixinsong-b} \
      $out/share/fonts/truetype/
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "KaiXinSong";
    homepage = "http://www.guoxuedashi.net/zidian/bujian/KaiXinSong.php";
    license = with lib.licenses; [ unfreeRedistributable ];
  };
}
