{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  sqlite,
  stdenv,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "openhuman";
  version = "0.63.21";

  src = stdenv.mkDerivation {
    name = "openhuman-source-${version}";
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-Ee72Ai6usJaWlU2PPJG25ncjUdGzbIu7CEd2Ze7UgSw=";
    nativeBuildInputs = [
      pkgs.git
      pkgs.cacert
    ];
    buildCommand = ''
      export HOME=$(pwd)
      git config --global url."https://github.com/".insteadOf git@github.com:
      git clone --depth 1 --branch v${version} https://github.com/tinyhumansai/openhuman.git $out
      cd $out
      git submodule update --init --recursive
      find $out -name .git -type d -exec rm -rf {} +
      find $out -name .git -type f -exec rm -f {} +
    '';
  };

  cargoHash = "sha256-+CUglRw09mHoSDRtME8QxOTeMMmXdolnYN+yeilfUx8=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    sqlite
  ];

  doCheck = false;

  meta = with lib; {
    description = "OpenHuman core business logic and RPC server";
    homepage = "https://github.com/tinyhumansai/openhuman";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "openhuman-core";
  };
}
