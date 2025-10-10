{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchzip,
  clickgen,
  hyprcursor,
  xcur2png,
  bash,
}:

stdenvNoCC.mkDerivation rec {
  pname = "bibata-cursors-rosepine-hyprcursor";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = "bibata-cursor";
    rev = "${version}";
    hash = "sha256-73DrcBnJQCmqgBs/Och034+AyexGeCULw0BDTJwMRjQ=";
  };

  bitmaps = fetchzip {
    url = "https://github.com/adam01110/bibata-cursor/releases/download/${version}/Bibata-Modern-Rosepine.zip";
    hash = "sha256-vUpZwfm/TqdZVeq6yg9ETYdLqsBzkzC/YkJH4CJbVdc=";
  };

  nativeBuildInputs = [
    clickgen
    hyprcursor
    xcur2png
    bash
  ];

  buildPhase = ''
    runHook preBuild

    # Build xcursors
    ctgen build.toml -d $bitmaps -n 'Bibata-Modern-Rosepine' -c 'Rosepine Bibata modern XCursors'

    # build hyprcursors
    bash hyprcursor-build.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -dm 0755 $out/share/icons
    cp -rf bin/*-hyprcursor $out/share/icons/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bibata modern cursor (Rosepine & left variant)";
    homepage = "https://github.com/adam01110/bibata-cursor";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
