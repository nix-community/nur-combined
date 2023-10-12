{ lib
, pkgs
, stdenv
, clangStdenv
, rustPlatform
, hostPlatform
, targetPlatform
, pkg-config
, rustfmt
, cargo
, rustc
}:

rustPlatform.buildRustPackage rec {
  src = pkgs.fetchFromGitHub {
    owner = "Rutherther";
    repo = "sequence-detector";
    rev = "c447c0d83877907c3ade8a2e9b4f659d4ef92904";
    hash = "sha256-Bo+IE3aBEHFsnKPrcSVe9x1QNmB8BgsavVmh7UBP4Rg=";
  };

  cargoHash = "sha256-JWg99wgauaoo6Jbt+MARWuHrjgnfTDGWBla56l97o+A=";

  name = "sequence_detector";
  version = "0.1.0";

  nativeBuildInputs = [
    rustfmt
    pkg-config
    cargo
    rustc
  ];

  checkInputs = [ cargo rustc ];
  doCheck = true;

  meta = {
    license = [ lib.licenses.mit ];
    maintainers = [];
  };
}
