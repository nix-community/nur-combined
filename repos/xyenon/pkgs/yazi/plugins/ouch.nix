{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation {
  __structuredAttrs = true;

  pname = "ouch";
  version = "0.7.2-unstable-2026-08-20";
  src = fetchFromGitHub {
    owner = "ndtoan96";
    repo = "ouch.yazi";
    rev = "cfe4f507ef7337c8ad4c90eef68ea91fc6694759";
    hash = "sha256-t1kUo4+YODeTG9d5Yq/vxElcmRHIebC5TRv+uDGG88c=";
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
