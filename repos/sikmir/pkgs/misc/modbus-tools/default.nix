{ lib, stdenv, rustPlatform, fetchFromGitLab, IOKit }:

rustPlatform.buildRustPackage rec {
  pname = "modbus-tools";
  version = "0.2";

  src = fetchFromGitLab {
    owner = "alexssh";
    repo = "modbus-tools";
    rev = "v${version}";
    hash = "sha256-PA8EuZa2jKkd/pn6UGGJ6f7jac1bN2sS2fX3qmYVduQ=";
  };

  cargoPatches = [ ./cargo-lock.patch ];
  cargoHash = "sha256-Fd8B7PmcWUeWg5QxNB4twP0buEyPznaj/LCPisbPWLQ=";

  buildInputs = lib.optional stdenv.isDarwin IOKit;

  meta = with lib; {
    description = "Tool(s) for working with Modbus protocol";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
