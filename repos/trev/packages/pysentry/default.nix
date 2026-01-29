{
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pysentry";
  version = "0.3.16";

  src = fetchFromGitHub {
    owner = "nyudenkov";
    repo = "pysentry";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2sCk195abSkp6AdrOVimpkvNIjt62C33WwNsvs3N/Ag=";
  };

  cargoHash = "sha256-y5uNCc165MALQ82OE3p7quAX8daw8swrqOga/XYfQFo=";

  meta = {
    description = "Scans your Python dependencies for known security vulnerabilities";
    mainProgram = "pysentry";
    homepage = "https://github.com/nyudenkov/pysentry";
    changelog = "https://github.com/nyudenkov/pysentry/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
