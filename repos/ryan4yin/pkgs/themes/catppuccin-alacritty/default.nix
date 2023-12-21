{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "catppuccin-alacritty";
  version = "yaml";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "alacritty";
    rev = version;
    hash = "sha256-w9XVtEe7TqzxxGUCDUR9BFkzLZjG8XrplXJ3lX6f+x0=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r * $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "Soothing pastel theme for Alacritty";
    homepage = "https://github.com/catppuccin/alacritty";
    license = licenses.mit;
    maintainers = with maintainers; [];
    mainProgram = "alacritty";
    platforms = platforms.all;
  };
}
