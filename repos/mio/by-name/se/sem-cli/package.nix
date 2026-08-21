{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  apple-sdk,
}:

rustPlatform.buildRustPackage rec {
  pname = "sem-cli";
  version = "0.22.1";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-MaISe6TG4I5zb6hSRsBj5ENe5JSh7MjQ+QIDWDhxTo0=";
  };

  cargoHash = "sha256-/ZxkR3YmUgswxuTCQHoGyoDhuU3JeDbrjPsTSLf9WKc=";

  sourceRoot = "${src.name}/crates";

  patches = [
    ./disable-telemetry.patch
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk
  ];

  # Cargo's only default feature is `self-update` (GitHub download/replace +
  # background "new version" checks). `--no-default-features` turns that off so
  # Nix owns updates; it does not affect diff/blame/etc. or telemetry (patched).
  cargoBuildFlags = [
    "--package"
    "sem-cli"
    "--no-default-features"
  ];

  checkFlags = cargoBuildFlags;

  # Tests require git and specific environment setups that might fail in sandbox
  doCheck = false;

  meta = {
    description = "Semantic version control CLI by Ataraxy Labs";
    homepage = "https://github.com/Ataraxy-Labs/sem";
    license = with lib.licenses; [
      mit
      asl20
    ];
    mainProgram = "sem";
    maintainers = with lib.maintainers; [ ];
  };
}
