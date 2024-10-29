{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:

rustPlatform.buildRustPackage rec {
  pname = "sha3sum";
  version = "1.2.0";

  src = fetchFromGitLab {
    owner = "kurdy";
    repo = "sha3sum";
    rev = "v${version}";
    hash = "sha256-SPAwzkSbGzIa6OC5ilzYvgmbRhT8WO+Y92x8Rlgb6SA=";
  };

  cargoHash = "sha256-dsaU4JkStXVkICfS4qo90KQjrvJunToP64d7QAj6tFs=";

  meta = with lib; {
    description = "Sha3sum - compute and check sha3xxx message digest.\r\nThe command is similar to the GNU commands shaXXXsum. It use and wrap  the RustCrypto/hashes lib";
    homepage = "https://gitlab.com/kurdy/sha3sum";
    changelog = "https://gitlab.com/kurdy/sha3sum/-/blob/${src.rev}/CHANGELOG";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "sha3sum";
  };
}
