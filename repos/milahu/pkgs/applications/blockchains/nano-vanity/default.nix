{ lib
, rustPlatform
, fetchFromGitHub
, ocl-icd
}:

rustPlatform.buildRustPackage rec {
  pname = "nano-vanity";
  version = "unstable-2024-04-20";

  src = fetchFromGitHub {
    owner = "PlasmaPower";
    repo = "nano-vanity";
    rev = "caa72745d63cb940677f5753249086b0af420b84";
    hash = "sha256-PagDuLguR9aZjc8etL9IV4roA8J3JJvoOWYnWGbry5k=";
  };

  cargoHash = "sha256-dyYeZ3xDgqE7CDogwnm5vJ4oxGu7aSJTYCMsiDIoRvE=";

  buildInputs = [
    # fix: ld: cannot find -lOpenCL: No such file or directory
    ocl-icd
  ];

  meta = with lib; {
    description = "A NANO vanity address generator (supports OpenCL)";
    homepage = "https://github.com/PlasmaPower/nano-vanity";
    license = licenses.bsd2;
    maintainers = with maintainers; [ ];
    mainProgram = "nano-vanity";
  };
}
