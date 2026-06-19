{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-QCVYmJ/Q0IITv6YFeOZYsLfpOGRDoS+LQWvCRAxPCbE=";
  };

  cargoHash = "sha256-DOKDvL1eP19fu3fCbYzZ4E6/72ksh9UNDxLOedPHvRI=";
})
