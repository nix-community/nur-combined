{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation {
  pname = "lain-kde-splashscreen";
  version = "0-unstable-2026-08-12";

  src = fetchFromGitHub {
    owner = "dgudim";
    repo = "themes";
    rev = "c2059d01888d97ca29c36d755c063fa9c56e486a";
    hash = "sha256-H+1GI7IaV4SwS173+PDx26h7UFEuuwu8Ru8i7c+6jIg=";
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
