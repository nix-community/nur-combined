{
  stdenv,
  lib,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cohomcalg";
  version = "0.32";

  src = fetchFromGitHub {
    owner = "BenjaminJurke";
    repo = "cohomCalg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9kKKfb8STiCjaHiWgYEQsERNTnOXlwN8axIBJHg43zk=";
  };

  enableParallelBuilding = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/cohomcalg $out/bin/cohomcalg
    runHook postInstall
  '';

  meta = {
    description = "Software package for computation of sheaf cohomologies for line bundles on toric varieties";
    license = lib.licenses.gpl3Plus;
    homepage = "https://github.com/BenjaminJurke/cohomCalg/";
    mainProgram = "cohomcalg";
  };
})
