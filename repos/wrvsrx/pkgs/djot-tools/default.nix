{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-E13puEBfmKEc9OgdcRBQnx3LQRWLR4jqSsr1q9MhMVg=";
  };

  cargoHash = "sha256-YSUlueFPuAA0K2JZFEdPua4nJhdrZHEThIuI9xirlD4=";
})
