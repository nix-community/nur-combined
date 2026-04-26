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
  version = "11.4.0.1";

  src = fetchurl rec {
    name = "QQMusicMac11.4.0Build01.dmg";
    url = "https://web.archive.org/web/20260426065539if_/https://dldir.y.qq.com/ecosfile/music_clntupate/mac/other/${name}?sign=1777186510-1yNmUirN98T1Ihr5-0-28a33d58ba384318ecf87f7c680e0c10";
    hash = "sha256-JbeiIpW7kcnjSlWv9ZxS9z1LtE+HGetz+XEOvBI4HqM=";
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
