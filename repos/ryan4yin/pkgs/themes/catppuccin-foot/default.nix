{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-foot";
  version = "unstable-2023-04-09";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "foot";
    rev = "009cd57bd3491c65bb718a269951719f94224eb7";
    hash = "sha256-gO+ZfG2Btehp8uG+h4JE7MSFsic+Qvfzio8Um0lDGTg=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for foot";
    homepage = "https://github.com/catppuccin/foot";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "foot";
    platforms = platforms.all;
  };
}
