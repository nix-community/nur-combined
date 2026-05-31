{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "modbus-tools";
  version = "0.2-unstable-2025-02-17";

  src = fetchFromGitLab {
    owner = "alexs-sh";
    repo = "modbus-tools";
    rev = "79b3bcf54b882d8bfec29f5d231c90e7b0f67119";
    hash = "sha256-XBIdWYeuuqxwtPuhnZ7BstRlELIf9YdN2Sy9TEywDR0=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  meta = {
    description = "Tool(s) for working with Modbus protocol";
    homepage = "https://github.com/alexs-sh/modbus-tools";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
  };
})
