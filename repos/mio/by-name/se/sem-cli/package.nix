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
  version = "0.25.0";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-qv9xLNK74dNhffUgyMDW7stEQgn+NgzBgEHxeyqKvVw=";
  };

  cargoHash = "sha256-5g77gr5tx6owE+5kzrdg9F1sFEK6GzdtUsuDF3sRi1s=";

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
