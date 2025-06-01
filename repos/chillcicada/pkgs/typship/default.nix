{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  perl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "typship";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "sjfhsjfh";
    repo = "typship";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LDiKAQmzEgzFJH2NAR3FYsO4SmH5uAEOa6I4A0FnwJk=";
  };

  cargoHash = "sha256-t4Vnww49CnkBSRsAWKxSpJffuUuqFAxqUN0GtoxnKLY=";

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [ openssl ];

  meta = with lib; {
    description = " A Typst package CLI tool";
    homepage = "https://github.com/sjfhsjfh/typship";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "typship";
  };
})
