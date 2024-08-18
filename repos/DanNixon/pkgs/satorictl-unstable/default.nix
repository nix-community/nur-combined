{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "satorictl-unstable";
  version = "2024-08-14";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "satori";
    rev = "71a539ce1770af8c69b4657994e90e9be3c6e801";
    hash = "sha256-8FH3iqAdc8URpH94vCpqs++TGldeDh1c69+WluzHRZ4=";
  };

  cargoHash = "sha256-Tik1PRMpaurzc0FuAGglOKx225OHGJZGfQW+IPiZBfo=";

  buildAndTestSubdir = "ctl";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = {
    description = "CLI control tool for Satori, a very simple NVR for IP cameras.";
    homepage = "https://github.com/DanNixon/satori";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
