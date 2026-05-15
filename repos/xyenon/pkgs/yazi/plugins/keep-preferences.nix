{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "keep-preferences";
  version = "0-unstable-2026-05-15";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "keep-preferences.yazi";
    rev = "f6656322e059df2384b1e3b37461e362438879f9";
    hash = "sha256-eRlF78sixUVHWuYFml65xY7W0rKGDholqpggUuatd1c=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Keep Yazi manager preferences per tab and directory";
    homepage = "https://github.com/XYenon/keep-preferences.yazi";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
