{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-tvxK03QmGcaMA0cfZQC01b9ROsXMpQOsmKCspJbpWM8=";
  };

  cargoHash = "sha256-pvm+f7gL5rkBh5Qq7aA/+Lp8aqvJUh8l7xNpKYBUt78=";
})
