{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  stdenv,
  darwin,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "koji";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "cococonscious";
    repo = "koji";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+xtq4btFbOfiyFMDHXo6riSBMhAwTLQFuE91MUHtg5Q=";
  };

  cargoHash = "sha256-WiFXDXLJc2ictv29UoRFRpIpAqeJlEBEOvThXhLXLJA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ]
  ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.Security ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doCheck = false;
  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = {
    description = "An interactive CLI for creating conventional commits";
    homepage = "https://github.com/its-danny/koji";
    changelog = "https://github.com/its-danny/koji/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
