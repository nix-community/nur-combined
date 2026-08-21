{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "lain-kde-splashscreen";
  version = "0-unstable-2026-08-20";

  src = fetchFromGitHub {
    owner = "dgudim";
    repo = "themes";
    rev = "a6c34bb8d658edaac9085b01214a34812eaead2b";
    hash = "sha256-Hkl4mulcYeUuRuS4bk3kFZs3V64rmGgECW+y1K4203w=";
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
