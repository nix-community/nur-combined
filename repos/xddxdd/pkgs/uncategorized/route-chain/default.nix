{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "route-chain";
  version = "1.1.0-unstable-2026-01-09";
  src = fetchFromGitHub {
    owner = "xddxdd";
    repo = "route-chain";
    rev = "19cb38b50ab74074c7159c72f77ca7401a0a04e6";
    hash = "sha256-lYYdu2sQhf/AYR9j88IGXIg8S5ApMyAYJH4RTGu3h78=";
  };
  enableParallelBuilding = true;
  installPhase = ''
    runHook preInstall

    make install PREFIX=$out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Small app to generate a long path in traceroute";
    homepage = "https://github.com/xddxdd/route-chain";
    license = lib.licenses.unlicense;
    mainProgram = "route-chain";
  };
})
