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
  pname = "bibata-cursors-gruvbox-dark-hyprcursor";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "adam01110";
    repo = "bibata-cursor";
    rev = "${version}";
    hash = "sha256-73DrcBnJQCmqgBs/Och034+AyexGeCULw0BDTJwMRjQ=";
  };

  bitmaps = fetchzip {
    url = "https://github.com/adam01110/bibata-cursor/releases/download/${version}/Bibata-Modern-Gruvbox-Dark.zip";
    hash = "sha256-MHR5mhZJOXJsUvcJU41ZRe1dFFEcay93NbYllD4i4GM=";
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
    ctgen build.toml -d $bitmaps -n 'Bibata-Modern-Gruvbox-Dark' -c 'Gruvbox dark Bibata modern XCursors'

    # Build hyprcursors
    bash hyprcursor-build.sh

    # Ensure manifest names match the hyprcursor pack directories
    for manifest in bin/*-hyprcursor/manifest.hl; do
      if [ -f "$manifest" ]; then
        pack_name=$(basename "$(dirname "$manifest")")
        sed -i "s/^name = .*/name = ''${pack_name}/" "$manifest"
      fi
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -dm 0755 $out/share/icons
    cp -rf bin/*-hyprcursor $out/share/icons/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bibata modern cursor (Gruvbox dark & left variant)";
    homepage = "https://github.com/adam01110/bibata-cursor";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
