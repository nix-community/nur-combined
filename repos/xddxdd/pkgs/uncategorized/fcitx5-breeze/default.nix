{
  fetchurl,
  stdenv,
  lib,
  python3,
  inkscape,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "fcitx5-breeze";
  version = "3.1.0";
  src = fetchurl {
    url = "https://gitlab.com/scratch-er/fcitx5-breeze/-/archive/v${finalAttrs.version}/fcitx5-breeze-v${finalAttrs.version}.tar.gz";
    hash = "sha256-rRVRUY69M5Nz8MwarePlqy2JIOX8MP0nz6Ia2pwmkTA=";
  };
  nativeBuildInputs = [
    python3
    inkscape
    writableTmpDirAsHomeHook
  ];

  buildPhase = ''
    runHook preBuild

    python build.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fcitx5/themes
    ./install.sh $out

    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fcitx5 theme to match KDE's Breeze style";
    homepage = "https://github.com/scratch-er/fcitx5-breeze";
    license = lib.licenses.gpl3Only;
  };
})
