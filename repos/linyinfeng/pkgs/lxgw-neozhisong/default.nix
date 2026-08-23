{
  sources,
  stdenvNoCC,
  lib,
}:
stdenvNoCC.mkDerivation {
  pname = "lxgw-neozhisong";
  version = sources.lxgw-neozhisong.version;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    install -Dm444 ${sources.lxgw-neozhisong.src} "$out/share/fonts/truetype/LXGWNeoZhiSong.ttf"
    install -Dm444 ${sources.lxgw-neozhisong-plus.src} "$out/share/fonts/truetype/LXGWNeoZhiSongPlus.ttf"
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/lxgw/LxgwNeoZhiSong";
    description = "霞鹜新致宋 (LXGW Neo Zhi Song), an open-source Chinese serif font derived from LXGW WenKai";
    license = lib.licenses.ofl;
    maintainers = with lib.maintainers; [ yinfeng ];
  };
}
