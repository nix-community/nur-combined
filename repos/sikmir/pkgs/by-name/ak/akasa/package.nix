{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  perl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "akasa";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "akasamq";
    repo = "akasa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ff5B8vJ0r0VGf72oiEUHLI1SbuNupBQ+w59MqVZO8/Q=";
  };

  cargoHash = "sha256-+AAojzk67nkjcChkx55Qbr5Zskn9Qq4DZwfxynfsoew=";

  cargoPatches = [ ./cargo-lock.patch ];

  nativeBuildInputs = [ perl ];

  buildInputs = [ openssl ];

  meta = {
    description = "A high performance, low latency and high extendable MQTT server in Rust";
    homepage = "https://github.com/akasamq/akasa";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "akasa";
  };
})
