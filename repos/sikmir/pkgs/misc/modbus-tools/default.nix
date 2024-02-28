{ lib, stdenv, rustPlatform, fetchFromGitLab, IOKit }:

rustPlatform.buildRustPackage rec {
  pname = "modbus-tools";
  version = "0.2";

  src = fetchFromGitLab {
    owner = "alexs-sh";
    repo = "modbus-tools";
    rev = "v${version}";
    hash = "sha256-PA8EuZa2jKkd/pn6UGGJ6f7jac1bN2sS2fX3qmYVduQ=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  buildInputs = lib.optional stdenv.isDarwin IOKit;

  meta = with lib; {
    description = "Tool(s) for working with Modbus protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
