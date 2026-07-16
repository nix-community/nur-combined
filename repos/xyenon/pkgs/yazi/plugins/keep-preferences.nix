{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "keep-preferences";
  version = "0-unstable-2026-07-15";
  src = fetchFromGitHub {
    owner = "XYenon";
    repo = "keep-preferences.yazi";
    rev = "0d32befc027b2ad31b8893bb2832f0f160442a0c";
    hash = "sha256-fdZIouyrWxcFGv51NVYylQRba6PGEzFqEP6mrUQiC9s=";
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
