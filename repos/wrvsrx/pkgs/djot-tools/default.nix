{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-PAW97WxBkseNpkoeWTDRCsvSEYjIOtzLYv4D5jrxUPQ=";
  };

  cargoHash = "sha256-lEojo+kPVRrBW2qHcJNXGHAuDyE1xazgOOu1Qo//VE4=";
})
