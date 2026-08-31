{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "breathe-cli";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "marekkowalczyk";
    repo = "breathe-cli";
    rev = "v${version}";
    hash = "sha256-v4hFZVfvDgGWoSBPxdlwXJJZ/2TAUskpo6dQ//G0BJw=";
  };

  format = "other";

  installPhase = ''
    runHook preInstall
    install -Dm755 breathe.py $out/bin/breathe
    runHook postInstall
  '';

  meta = {
    description = "Paced resonance breathing for vagal tone training";
    homepage = "https://github.com/marekkowalczyk/breathe-cli";
    license = lib.licenses.mit;
    mainProgram = "breathe";
    maintainers = with lib.maintainers; [ ];
  };
}
