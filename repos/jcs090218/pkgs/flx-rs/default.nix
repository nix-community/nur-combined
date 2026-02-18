{
  rustPlatform,
  fetchFromGitHub,
  lib,
}:

rustPlatform.buildRustPackage rec {
  pname = "flx-rs";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "the-flx";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-OFm0Jk06Mxzr4F7KrMBGFqcDSuTtrMvBSK99bbOgua4=";
  };

  cargoHash = "sha256-bBCQf7Ru0U+70QWDC87urNJMejqWk3AwNiM19GeuhXc=";
  doCheck = false;

  meta = {
    description = "Rewrite emacs-flx in Rust for dynamic modules";
    homepage = "https://github.com/the-flx/flx-rs";
    license = lib.licenses.mit;
  };
}
