{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "ouch";
  version = "0.7.2-unstable-2026-09-12";
  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "596b66697f40fd8b36f1063fed22f64354f74c1f";
    hash = "sha256-RW49EJiEyPodkKpUd0Ad0ztr/obODpC6ShWIee8aT3Q=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -r . $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--version-regex=^v(.*)$"
    ];
  };

  meta = {
    description = "Yazi plugin to preview archives";
    homepage = "https://github.com/ndtoan96/ouch.yazi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xyenon ];
  };
}
