{
  lib,
  rustPlatform,
  fetchFromGitea,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-03-03";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "ae7f636ad9fe3f7d0b227b153ceb8d6da46189ff";
    hash = "sha256-d5GRlVqwZiYA5V6DI4JLk0+oyHzJI8E1iqMbQGR7fLo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-OtqTaiLGvlurNXBaTXz0XrggPvWEkxUINuS3I3S/isc=";

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
