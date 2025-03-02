{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  openssl,
  pkg-config,
  darwin,
}:

rustPlatform.buildRustPackage rec {
  pname = "prr";
  version = "0.20.0";

  src = fetchFromGitHub {
    owner = "danobi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-duoC3TMgW+h5OrRCbqYPppMtnQBfS9R7ZpHQySgPRv4=";
  };

  cargoHash = "sha256-PuPCm6IyX/dBcigBhroNaKDwY4TypUDjVODy+2iUix0=";

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  nativeBuildInputs = [ pkg-config ];
  doCheck = false;

  meta = with lib; {
    description = "Tool that brings mailing list style code reviews to Github PRs";
    homepage = "https://github.com/danobi/prr";
    license = licenses.gpl2Only;
    mainProgram = "prr";
    maintainers = with maintainers; [ evalexpr ];
  };
}
