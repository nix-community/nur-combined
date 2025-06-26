{
  lib,
  rustPlatform,
  fetchFromGitLab,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "modbus-tools";
  version = "0.2";

  src = fetchFromGitLab {
    owner = "alexs-sh";
    repo = "modbus-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PA8EuZa2jKkd/pn6UGGJ6f7jac1bN2sS2fX3qmYVduQ=";
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
