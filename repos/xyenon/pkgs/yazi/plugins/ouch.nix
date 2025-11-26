{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "ouch";
  version = "0.7.0-unstable-2025-11-25";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "cfb91404d3d83bcf7bbf90d689d226699b0e4147";
    hash = "sha256-6TyKPsapXJMiSRFrKRfP/hamOiG6LfgbPp7flh5tKoo=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
