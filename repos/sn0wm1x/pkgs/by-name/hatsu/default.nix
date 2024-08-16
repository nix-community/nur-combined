{ fetchFromGitHub
, lib
, rustPlatform
}:
rustPlatform.buildRustPackage rec {
  pname = "hatsu";
  version = "0.3.0-beta.1";

  src = fetchFromGitHub {
    owner = "importantimport";
    repo = "hatsu";
    rev = "v${version}";
    hash = "sha256-IzQVQ5wk6mAPGCDBjnLKYJ7/7vw0Hsj07lg89RbAk28=";
  };

  cargoHash = "sha256-8wsvmzv3gCxKClweku4VVRnX1gI2CTvJHfnaABVsj/Q=";

  meta = {
    description = "Self-hosted and fully-automated ActivityPub bridge for static sites";
    homepage = "https://github.com/importantimport/hatsu";
    license = lib.licenses.agpl3Only;
    mainProgram = "hatsu";
    maintainers = with lib.maintainers; [ kwaa ];
    platforms = lib.platforms.linux;
  };
}
