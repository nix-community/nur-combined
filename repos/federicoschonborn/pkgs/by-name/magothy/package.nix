{
  lib,
  rustPlatform,
  fetchFromGitea,
  versionCheckHook,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-03-23";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "ae7100264b1e5cd427c24ad9a07563efa2e23cfa";
    hash = "sha256-u7owKktKnxAsVwMyf8+NrI6SHALTW9DE2EmpX6ih2r0=";
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
