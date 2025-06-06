{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.2.0-unstable-2025-06-05";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "c45bac1f1692a07743dcd040b5ea9efa19d0a4f5";
    hash = "sha256-AOhtZzLSW7+ss0zPfcUpp6k7SSsKOMQOvAY7xbmmr3A=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-Omc+9/DO3ALUy8m5uYldPtFGoX2AmnPkQSZ2KDOhrxo=";

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Jq like markdown processing tool";
    homepage = "https://github.com/harehare/mq";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "mq";
    broken = versionOlder rustc.version "1.85.0";
  };
}
