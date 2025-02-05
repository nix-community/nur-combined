{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:

stdenvNoCC.mkDerivation rec {
  pname = "genshin-data";
  version = "2025-01-01";

  src = fetchFromGitHub {
    owner = "DimbreathBot";
    repo = "AnimeGameData";
    rev = "fec96ae9346cc9184b5b9db7edcde88db7dd0ad4";
    hash = "sha256-vRuJD+YMCode/iz8Z5VWPgYooYo7h9KvynrzzU9tAsY=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r ${src}/* $out
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=main"
    ];
  };

  meta = {
    description = "Repository containing the data for the game Genshin Impact.";
    homepage = "https://github.com/DimbreathBot/AnimeGameData";
    maintainers = with lib.maintainers; [ codgician ];
  };
}
