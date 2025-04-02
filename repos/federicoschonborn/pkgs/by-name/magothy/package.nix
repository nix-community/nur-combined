{
  lib,
  rustPlatform,
  fetchFromGitea,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-03-30";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "04e73cf2d2aadf152a1cc46e29f9485a6b34af9e";
    hash = "sha256-tfoDoBAQ4q7b1f5FruWEgnXOsO4GClHSPFtMo2pUjDM=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-OtqTaiLGvlurNXBaTXz0XrggPvWEkxUINuS3I3S/isc=";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  # Does not have a proper version yet ("0.0.0").
  dontVersionCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };

  meta = {
    mainProgram = "magothy";
    description = "A hardware profiling application for Linux";
    homepage = "https://codeberg.org/serebit/magothy";
    license = with lib.licenses; [
      asl20
      cc0
    ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
