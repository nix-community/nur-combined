{ rustPlatform, fetchFromGitHub, lib, ... }:
rustPlatform.buildRustPackage {
  pname = "artworks";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mrtnvgr";
    repo = "artworks";
    rev = "65db7dca20dd0c98f15213d1c1902ca35b12b8cd";
    hash = "sha256-fhFQBb8ez+zcmmFfI6IDGshEfPGe9lZacCzgyuiHjFc=";
  };

  cargoHash = "sha256-R/iNFG9zIoc7j9qeG9glU36DY++s0+elnHNoCoSL5DQ=";

  meta = with lib; {
    description = "Embed album covers to audio files";
    homepage = "https://github.com/mrtnvgr/artworks";
    license = licenses.gpl3;
    mainProgram = "artworks";
  };
}
