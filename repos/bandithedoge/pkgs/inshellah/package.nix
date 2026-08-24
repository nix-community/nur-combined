{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "inshellah";
  version = "0.1.2";
  src = fetchFromGitHub {
    owner = "manic-systems";
    repo = "inshellah";
    rev = "4e0da58e610f4cc3d1d3ab11b27f61afa8be99c1";
    hash = "sha256-Hl0PLWo6xyhSJaQtOkrNGQFxqBx5AdP1R1veMD22cMc=";
  };
  cargoHash = "sha256-AEokhS9NjGp4DLvqK2CMlN3Pauz8ASSTBe4YLkh8Ntw=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "The last word in nushell completions";
    homepage = "https://github.com/manic-systems/inshellah";
    license = lib.licenses.eupl12;
    platforms = lib.platforms.unix;
    mainProgram = "inshellah";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
