{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "lain-kde-splashscreen";
  version = "0-unstable-2025-11-30";

  src = fetchFromGitHub {
    owner = "dgudim";
    repo = "themes";
    rev = "496cdec18fc5d89e9e9bbb93faca6d481a006b31";
    hash = "sha256-GGmsYDlalnSCrd4Mw/mCA2ghNm3wq/1LjaDdsYdKBcA=";
  };
  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/plasma/look-and-feel"
    cp -aR KDE-loginscreens/Lain "$out/share/plasma/look-and-feel/Lain"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Lain themed KDE Plasma splash screen";
    homepage = "https://github.com/dgudim/themes";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
