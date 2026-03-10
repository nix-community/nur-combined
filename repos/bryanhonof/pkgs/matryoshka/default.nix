{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "matryoshka";
  version = "main";

  src = fetchFromGitHub {
    owner = "yogthos";
    repo = "Matryoshka";
    rev = finalAttrs.version;
    hash = "sha256-EUQhcPV7UKUCc8qTfnSTuwImdj0kpS9EOBYOO6VwE5o=";
  };

  npmDepsHash = "sha256-dgu0vMJcLt6cpYt0agszBrwGtcgRLs6p/hZc10I6Xoo=";

  meta = with lib; {
    description = "A Local Recursive Language Model";
    homepage = "https://github.com/yogthos/Matryoshka";
    license = licenses.unfree;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.linux;
    mainProgram = "rlm";
  };
})
