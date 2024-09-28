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

  cargoHash = "sha256-+/nFGxw1HTVoP+AwgnmFRAL9MAWTwuzUSIcCuL6Oo5M=";
  doCheck = false;

  meta = {
    description = "Rewrite emacs-flx in Rust for dynamic modules";
    homepage = "https://github.com/the-flx/flx-rs";
    license = lib.licenses.mit;
  };
}
