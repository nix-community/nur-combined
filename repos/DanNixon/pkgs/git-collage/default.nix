{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  openssl,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "git-collage";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "DanNixon";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-LznCU6SlYcsPK3A5OXUwhVEZWdOm4utIGznZCEsHzo4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  cargoHash = "sha256-mO0EE5vjLqe1A/gjdNOkwxCWNCa9OvULwV6gkTh302Q=";

  meta = {
    description = "A tool for selectively mirroring Git repositories.";
    homepage = "https://github.com/DanNixon/${pname}";
    platforms = lib.platforms.unix;
    license = lib.licenses.mit;
  };
}
