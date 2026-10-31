{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "promptbox";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "dimfeld";
    repo = "promptbox";
    rev = "v0.3.1";
    hash = "sha256-ZhDu7kcPhPXPN5Eq5wnK+Ek3jxHTSviN2sN8ihQXsE0=";
  };

  patches = [ ./default_config.patch ];

  cargoHash = "sha256-F6c7GXnLCkLN4UNQErJPZpb6R2MqlXoGTEC3+ilkwAg=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  doCheck = false;

  meta = {
    description = "A CLI tool for managing and executing LLM prompt templates";
    homepage = "https://github.com/dimfeld/promptbox";
    license = lib.licenses.mit;
    mainProgram = "promptbox";
    platforms = lib.platforms.unix;
  };
}
