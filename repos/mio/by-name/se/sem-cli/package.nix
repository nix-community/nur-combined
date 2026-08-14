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
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-rzWV9QuZbHupRqVK7hGL6fsh8KQELkc8bvfQWoIfTrs=";
  };

  cargoHash = "sha256-0B947V49LLT3oZDXtYJFarDvZrynrE3PV9X4pTqc7z4=";

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
