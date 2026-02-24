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
  version = "3.3.1";

  src = fetchFromGitHub {
    owner = "cococonscious";
    repo = "koji";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8z7lx0aVmA2gbydeJOBDVM2s6rwZpDLRaw1yqErwhJ4=";
  };

  cargoHash = "sha256-dnidKrH/HSUpm8sU51G4e74NgyyO3v2sTK4eDKSJujA=";

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
