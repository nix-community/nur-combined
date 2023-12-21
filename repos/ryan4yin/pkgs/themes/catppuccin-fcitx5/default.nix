{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-fcitx5";
  version = "unstable-2022-10-05";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "fcitx5";
    rev = "ce244cfdf43a648d984719fdfd1d60aab09f5c97";
    hash = "sha256-uFaCbyrEjv4oiKUzLVFzw+UY54/h7wh2cntqeyYwGps=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Fcitx5";
    homepage = "https://github.com/catppuccin/fcitx5";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "fcitx5";
    platforms = platforms.all;
  };
}
