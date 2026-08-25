{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  dbus,
  openssl,
}:

rustPlatform.buildRustPackage rec {
  pname = "mesh-llm";
  version = "0.75.1";

  src = fetchFromGitHub {
    owner = "Mesh-LLM";
    repo = "mesh-llm";
    rev = "v${version}";
    hash = "sha256-RXjmM66u40cxnacbvTtCFJShMK4BM+MHOyJ2vQ7Gw60=";
  };

  cargoHash = "sha256-5O2R5IKlzmkmsWtWIKlnVLeK55balsqToh0cB7unFoY=";

  postPatch = ''
    substituteInPlace .cargo/config.toml \
      --replace-fail 'rustflags = ["-C", "link-arg=-fuse-ld=/opt/homebrew/bin/ld64.lld"]' 'rustflags = []'
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    dbus
  ];

  cargoBuildFlags = [
    "--package"
    "mesh-llm"
  ];

  cargoTestFlags = cargoBuildFlags;

  # The full workspace test suite expects live runtime/network fixtures.
  doCheck = false;

  meta = {
    description = "Distributed LLM runtime that pools GPUs and memory across machines";
    homepage = "https://github.com/Mesh-LLM/mesh-llm";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "mesh-llm";
    maintainers = with lib.maintainers; [ mio ];
    platforms = lib.platforms.unix;
  };
}
