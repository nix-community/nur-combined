{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "1.1.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kodama-community";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-td/QAWZ0th7V0FnPTupxu809aNPBJRAHHLhsIVSIIeE=";
  };

  cargoHash = "sha256-1fmoRjpIXoHc1t1m2X2LQ6COAp4hhSUt1yTMRdNSU+M=";

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kodama-community/kodama";
    downloadPage = "https://github.com/kodama-community/kodama/releases";
    changelog = "https://github.com/kodama-community/kodama/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
