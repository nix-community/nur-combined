{
  python3Packages,
  lib,
  beets,
  fetchFromGitHub,
  nix-update-script,
}:
python3Packages.buildPythonApplication {
  pname = "beets-lyricsmanager";
  version = "0.0.3-unstable-2025-12-16";
  src = fetchFromGitHub {
    owner = "zytx";
    repo = "beets-lyrics-manager";
    rev = "66ced5c782135ef6e476842854935b3babf9797d";
    hash = "sha256-mXp9ebOYVrS0inm6G26Azc01qLXx1BN5Mxf9PlsUxig=";
  };

  format = "setuptools";

  nativeBuildInputs = [ beets ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    description = "Beets plugin for automatically managing lyrics files (.lrc) when importing music files and synchronizing lyrics files when moving songs";
    homepage = "https://github.com/zytx/beets-lyrics-manager";
    license = lib.licenses.mit;
    inherit (beets.meta) platforms;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
