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
  version = "0.76.0";

  src = fetchFromGitHub {
    owner = "Mesh-LLM";
    repo = "mesh-llm";
    rev = "v${version}";
    hash = "sha256-A4AF1Bk1izEuprVFdL/eBlsXnjcAU7V1sUhx4lJjUWw=";
  };

  cargoHash = "sha256-5WnhmWYamul/SUcg84VnBzd5EaSaxnmZnmUeuzXJIuM=";

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
