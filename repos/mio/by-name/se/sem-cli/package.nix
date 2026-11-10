{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  stdenv,
  apple-sdk,
  writeShellApplication,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "sem-cli";
  version = "0.30.0";

  dontCargoUseSystemLibs = true;

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-JH8/UBO62VbPu4OR59FdaxdRubA0lGoI8+f7OtlwjJA=";
  };

  cargoHash = "sha256-DQOuJP1oG95zmPaqCja+mdDFyz+6/bmfcmDbHCtugH0=";

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

  passthru.updateScript = writeShellApplication {
    name = "update-sem-cli";
    text = ''
      export UPDATE_NIX_ATTR_PATH="sem-cli"
      exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
    '';
  };

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
