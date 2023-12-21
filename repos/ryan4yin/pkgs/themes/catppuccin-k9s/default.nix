{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-k9s";
  version = "unstable-2023-07-23";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "k9s";
    rev = "516f44dd1a6680357cb30d96f7e656b653aa5059";
    hash = "sha256-PtBJRBNbLkj7D2ko7ebpEjbfK9Ywjs7zbE+Y8FQVEfA=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for k9s";
    homepage = "https://github.com/catppuccin/k9s";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "k9s";
    platforms = platforms.all;
  };
}
