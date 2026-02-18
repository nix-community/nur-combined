{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "flxy-rs";
  version = "0.1.19";

  src = fetchFromGitHub {
    owner = "jcs-legacy";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-gSv5KloBRqrDXvWhYD1BZ8e+CN1ci+Pexde6+LCUsxw=";
  };

  cargoHash = "sha256-cMxirRk/6Odtlgo3S649a8dvHuxw+9fGSgP4UOG1dNo=";
  doCheck = false;

  meta = {
    description = "Fast, character-based search library in Rust";
    homepage = "https://github.com/jcs-legacy/flxy-rs";
    license = lib.licenses.mit;
  };
}
