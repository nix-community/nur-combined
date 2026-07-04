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
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-53jMRJY5LF6NaXJPN4ZXSI9+dDc/7xTh6PlXBiH7QA4=";
  };

  cargoHash = "sha256-43Ecif/3JHzuFDqhOxwcTeFGWEiHGygC9+D1WL++Bls=";

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
  ++ lib.optionals stdenv.isDarwin [
    apple-sdk
  ];

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
