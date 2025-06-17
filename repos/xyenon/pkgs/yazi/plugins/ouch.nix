{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  pname = "ouch";
  version = "0.6.0-unstable-2025-06-10";

  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "1ee69a56da3c4b90ec8716dd9dd6b82e7a944614";
    hash = "sha256-4KZeDkMXlhUV0Zh+VGBtz9kFPGOWCexYVuKUSCN463o=";
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
