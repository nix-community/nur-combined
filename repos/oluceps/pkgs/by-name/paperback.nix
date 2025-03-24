{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "paperback";
  version = "0-unstable-2024-08-14";

  src = fetchFromGitHub {
    owner = "cyphar";
    repo = "paperback";
    rev = "16f4655edf3be477525e7c84f56cf90f44339758";
    hash = "sha256-p2MTXuKZE/mPPjm/HQn14lsWuPnFQgluuG6qOyTeBWA=";
  };

  useFetchCargoVendor = true;

  cargoHash = "sha256-lFLQ3vVrTqABeHVdvEbrKLYCNpWgVkSKOg93xuu2CjU=";

  meta = with lib; {
    description = "Paper backup generator suitable for long-term storage";
    homepage = "https://github.com/cyphar/paperback";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "paperback";
  };
}
