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
  version = "0.78.1";

  src = fetchFromGitHub {
    owner = "Mesh-LLM";
    repo = "mesh-llm";
    rev = "v${version}";
    hash = "sha256-Au69tcuHXDyGUjRNOS+mGu3nhnaPQQqfoSVJS6jqqF0=";
  };

  cargoHash = "sha256-BMLcQnYgOSshqp+y16zomAUdsGX4bAPrv4iYYx96T3g=";
  postPatch = ''
    rm -f .cargo/config.toml
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
