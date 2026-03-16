# https://github.com/NixOS/nixpkgs/pull/454489
{
  fetchurl,
  lib,
  qqmusic,
  stdenvNoCC,
  undmg,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (qqmusic) pname;
  version = "10.9.6.2";

  src = fetchurl rec {
    name = "QQMusicMac10.9.6Build02.dmg";
    url = "https://web.archive.org/web/20251218055730if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1766037448-Ic5zxXL1l4JLZ321-0-a3bcd6b626a906f368d2568acddcfe04";
    hash = "sha256-aDDmKuaHOjfFw7B/+pp4e2Li/NehHKBIm5PGkRpF0uQ=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r QQMusic.app $out/Applications

    runHook postInstall
  '';

  meta = qqmusic.meta // {
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
})
