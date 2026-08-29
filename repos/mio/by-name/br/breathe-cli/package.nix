{
  lib,
  python3Packages,
  fetchFromGitHub,
}:

python3Packages.buildPythonApplication rec {
  pname = "breathe-cli";
  version = "1.11.1";

  src = fetchFromGitHub {
    owner = "marekkowalczyk";
    repo = "breathe-cli";
    rev = "v${version}";
    hash = "sha256-kIVVh+XfLm1hpt65zUdWpyI3kJohP3UPwZX8NfvLX8Y=";
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
