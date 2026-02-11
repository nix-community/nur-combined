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
    hash = "sha256-GTKccsRKzpu882MdIuB/SaePdzXOg3cR8Bu1UjedRDc=";
  };

  npmDepsHash = "sha256-ObFtyhw+8sSBEtlx00NLD4ueZgPgew6XyPr06UhN2Qo=";

  meta = with lib; {
    description = "A Local Recursive Language Model";
    homepage = "https://github.com/yogthos/Matryoshka";
    license = licenses.unfree;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.linux;
    mainProgram = "rlm";
  };
})
