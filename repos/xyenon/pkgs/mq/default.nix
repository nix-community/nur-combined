{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.2.3-unstable-2025-06-17";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "2c9a2b4ee3ea5f65bdd0b437438efab238552879";
    hash = "sha256-BNznCLSjU6Cb0h17IDcdw+nj1daOCGYdZh/RQ0jDMSc=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-m6wm6yIUAE6MOgTSiBgltJ2ydKVn6mvB3l00GjPf0Wk=";

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
