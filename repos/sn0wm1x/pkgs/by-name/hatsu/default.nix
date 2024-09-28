{ fetchFromGitHub
, lib
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "hatsu";
  version = "0.3.0-beta.6";

  src = fetchFromGitHub {
    owner = "importantimport";
    repo = "hatsu";
    rev = "refs/tags/v${version}";
    hash = "sha256-aPzbld07mPqq2TrSedL0Sr6kvhoqC+yG/4vC4CL5JD8=";
  };

  cargoHash = "sha256-uhyX5GiAJC8U6vXVPGGPzEMHn8/omci9Hgla3jHIGxg=";

  meta = {
    description = "Self-hosted and fully-automated ActivityPub bridge for static sites";
    homepage = "https://github.com/importantimport/hatsu";
    downloadPage = "https://github.com/importantimport/hatsu/releases";
    changelog = "https://github.com/importantimport/hatsu/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "hatsu";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
}
