{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  udev,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "spl-token-cli";
  version = "5.6.1";

  src = fetchFromGitHub {
    owner = "solana-program";
    repo = "token-2022";
    tag = "cli@v${finalAttrs.version}";
    hash = "sha256-7gOP19SESZMnfLPZfOP588TUstc01SRedn7uO7zrd4U=";
  };

  cargoHash = "sha256-kbpIyV4GFhebrZzVodnAxiJhgHnwb06JzGcRZCjchq0=";

  cargoBuildFlags = [ "-p spl-token-cli" ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    udev
    openssl
  ];
  strictDeps = true;

  doCheck = false;

  meta = with lib; {
    description = "A basic command-line for creating and using SPL Tokens";
    homepage = "https://github.com/solana-program/token-2022";
    license = licenses.asl20;
    platforms = platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "spl-token";
    broken = false;
  };
})
