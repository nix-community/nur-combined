{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, libgit2
, openssl
, zlib
, stdenv
, darwin
, testers
, koji
}:

rustPlatform.buildRustPackage rec {
  pname = "koji";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "its-danny";
    repo = "koji";
    rev = version;
    hash = "sha256-5x6MAWjqxSseahUqRgFCnIoUwGS5dwA6FWFNOnZRnVU=";
  };

  cargoHash = "sha256-yhva03FX6Yw1yURexYOmf5PtMIHhQd7+JqocWBr9f5g=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ libgit2 openssl zlib ]
    ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  env = { OPENSSL_NO_VENDOR = true; };

  passthru.tests.version = testers.testVersion { package = koji; };

  meta = with lib; {
    description = "An interactive CLI for creating conventional commits";
    homepage = "https://github.com/its-danny/koji";
    changelog =
      "https://github.com/its-danny/koji/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ nagy ];
  };
}
