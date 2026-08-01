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
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "koji";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "cococonscious";
    repo = "koji";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qKC4ayaNPSUh4wSElBWxk/P+Y2dFgCIFiMkI0/QztDY=";
  };

  cargoHash = "sha256-vdELHNH1GqR0LPY3SSNgSR3krZZ85Tsx6aTHve0Vhe8=";

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

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "An interactive CLI for creating conventional commits";
    homepage = "https://github.com/its-danny/koji";
    changelog = "https://github.com/its-danny/koji/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
