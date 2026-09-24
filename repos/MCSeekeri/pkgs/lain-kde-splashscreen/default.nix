{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "lain-kde-splashscreen";
  version = "0-unstable-2026-09-04";

  src = fetchFromGitHub {
    owner = "dgudim";
    repo = "themes";
    rev = "cf8557d1444ab35100e9f4c5ad8f063966520d9b";
    hash = "sha256-AAtosSrnT6qecL2lHzSMn+V8J5qCofZSTBCho0Oiw7M=";
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
    longDescription = ''
      A KDE Plasma splash screen featuring Lain (Serial Experiments Lain) themed
      artwork. Packaged as a Plasma look-and-feel package.
    '';
    homepage = "https://github.com/dgudim/themes";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
}
