{
  sources,
  stdenvNoCC,
  lib,
  ...
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fcitx5-themes-candlelight";
  inherit (sources.fcitx5-themes-candlelight) src version;

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    installPath="$out/share/fcitx5/themes/"
    mkdir -p "$installPath"
    mv * "$installPath"
  '';

  meta = {
    description = "fcitx5的简约风格皮肤——烛光";
    homepage = "https://https://github.com/thep0y/fcitx5-themes-candlelight";
    platforms = lib.platforms.all;
    license = lib.licenses.mit;
  };
})
