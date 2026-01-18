{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "matryoshka";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "yogthos";
    repo = "Matryoshka";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2CswwOhLGFQNB6ENWmLcJBWyQe+QpzP/rljW3g5Iz2w=";
  };

  npmDepsHash = "sha256-u1pOIz+JX2l9IgOL4msEV9LxK/A8WZU85SKLvBdvZjA=";

  meta = with lib; {
    description = "A Local Recursive Language Model";
    homepage = "https://github.com/yogthos/Matryoshka";
    license = licenses.unfree;
    maintainers = with maintainers; [ bryanhonof ];
    platforms = platforms.linux;
    mainProgram = "rlm";
  };
})
