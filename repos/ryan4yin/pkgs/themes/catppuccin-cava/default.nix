{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-cava";
  version = "unstable-2022-10-11";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "cava";
    rev = "ad3301b50786e22e31cbf4316985827d6f05845e";
    hash = "sha256-hYC6ExtroRy2UoxGNHAzKm9MlTdJSegUWToat4VoN20=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Cava";
    homepage = "https://github.com/catppuccin/cava";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "cava";
    platforms = platforms.all;
  };
}
