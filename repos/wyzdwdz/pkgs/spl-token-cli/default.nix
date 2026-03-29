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
  version = "5.5.0";

  src = fetchFromGitHub {
    owner = "solana-program";
    repo = "token-2022";
    tag = "cli@v${finalAttrs.version}";
    hash = "sha256-7zbMspIwfYBYurv8xROJUP22EcmkMyDi9LoOwpFHaW4=";
  };

  cargoHash = "sha256-mC033w6esSPOwZyFMyCcqIotWLaAMqznbaNci/dz3bU=";

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
    mainProgram = "spl-token";
    broken = false;
  };
})
