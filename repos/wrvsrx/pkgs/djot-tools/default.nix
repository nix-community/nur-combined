{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-ISR2DMSQpFceqpVbb90k3qs/cmY+J3raMEr1iheOOII=";
  };

  cargoHash = "sha256-sX1FeRwItm4uBuTdcRI5xvjMzilHjCBMSkL3NCPMLto=";
})
