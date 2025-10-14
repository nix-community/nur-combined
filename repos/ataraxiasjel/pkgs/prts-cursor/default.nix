{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "prts-cursor";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "AtaraxiaSjel";
    repo = finalAttrs.pname;
    rev = finalAttrs.version;
    hash = "sha256-pe8EQTmiJjmfO8nzfXGBY9Ocv7vvsYt5aPj2dASLJEY=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    cp -R PRTS $out/share/icons/
    cp -R PRTS-hypr $out/share/icons/
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "PRTS cursor theme";
    homepage = "https://github.com/AtaraxiaSjel/prts-cursor";
    license = licenses.unlicense;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
})
