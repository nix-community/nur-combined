{
  sources,
  stdenvNoCC,
  lib,
  python3,
  inkscape,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.fcitx5-breeze) pname version src;

  nativeBuildInputs = [
    python3
    inkscape
  ];

  buildPhase = ''
    runHook preBuild

    export HOME=$(pwd)
    python build.py

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fcitx5/themes
    ./install.sh $out

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Fcitx5 theme to match KDE's Breeze style";
    homepage = "https://github.com/scratch-er/fcitx5-breeze";
    license = licenses.gpl3Only;
  };
}
