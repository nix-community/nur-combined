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
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "sem";
    rev = "v${version}";
    hash = "sha256-erTyUSzK7Q9eW0NnhDZgnzLq+KdQGVpXB7ZHhpZ8yyU=";
  };

  cargoHash = "sha256-iNlR24RGjBL4RsMlL10ymc8VjaZxb+vlRAdSwu04VcA=";

  sourceRoot = "${src.name}/crates";

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
