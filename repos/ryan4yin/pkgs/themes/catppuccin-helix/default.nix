{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-helix";
  version = "unstable-2023-10-20";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "helix";
    rev = "8313c7250fcbbb22c6680db332669073ec6b28c2";
    hash = "sha256-qEXhj/Mpm+aqThqEq5DlPJD8nsbPov9CNMgG9s4E02g=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Helix";
    homepage = "https://github.com/catppuccin/helix";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "helix";
    platforms = platforms.all;
  };
}
