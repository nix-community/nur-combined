{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
  openssl,
  pkg-config,
  apple-sdk,
}:

rustPlatform.buildRustPackage rec {
  pname = "prr";
  version = "0.21.0";

  src = fetchFromGitHub {
    owner = "danobi";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-G8/T3Jyr0ZtY302AvYxhaC+8Ld03cVL5Cuflz62e0mw=";
  };

  cargoHash = "sha256-s/6fRbex4xACU64EGWsN459huTV56D92hBG0QPPDK5g=";

  buildInputs =
    [ openssl ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      apple-sdk
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
