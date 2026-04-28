{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openblas,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "runmat";
  version = "0.4.4";

  src = fetchFromGitHub {
    owner = "runmat-org";
    repo = "runmat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bLtDKDji+Lpb1GTPrxytYY3Hu0UVQHUp7mzM754tCdc=";
  };

  cargoHash = "sha256-LEFFWfWLcW7bHjegh6+jWGM2rg2Iiv6tTqJ6bICtLy8=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openblas
    openssl
  ];

  doCheck = false;

  meta = {
    description = "Open-source runtime for math. MATLAB syntax";
    homepage = "https://runmat.com/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ VZstless ];
    mainProgram = "runmat";
  };
})
