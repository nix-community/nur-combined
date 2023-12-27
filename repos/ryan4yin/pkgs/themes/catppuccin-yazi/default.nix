{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-yazi";
  version = "unstable-2023-10-22";

  src = fetchFromGitHub {
    owner = "yazi-rs";
    repo = "themes";
    rev = "8abf251851b9b7559f810a65932cd7735b202dfa";
    hash = "sha256-f8Mwacw8FoZ5S0wUdQcmtFZwrxDyabJfL7kPKhmOD1A=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r catppuccin/* $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for yazi";
    homepage = "https://github.com/yazi-rs/themes";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "yazi";
    platforms = platforms.all;
  };
}
