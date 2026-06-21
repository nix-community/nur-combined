{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-eiEoST1gTrVnWJvieSfn+cl0FeWBDYyws9mmi21hdas=";
  };

  cargoHash = "sha256-LWpkG81X/RRlI+BwA8hDyKdk9s8CjDotvGaSmB7F9FI=";
})
