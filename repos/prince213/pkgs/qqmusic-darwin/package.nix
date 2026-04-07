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
  version = "11.2.1.0";

  src = fetchurl rec {
    name = "QQMusicMac11.2.1Build00.dmg";
    url = "https://web.archive.org/web/20260407010813if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1775524061-0de0UBx42nduT2tg-0-9aede5ed735169671c08dac9e56578af";
    hash = "sha256-ldJT4k4MSr39abjo84FnvVABhMx5uvZmS2wPvVS8nUM=";
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
