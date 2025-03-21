{
  lib,
  rustPlatform,
  fetchFromGitea,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-03-17";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "f45b4a27b35723bd352126a57d8d75a0dc51ffa8";
    hash = "sha256-h+Ecf9G6JV8rFiwW7R7tD8/NbwS8H8VN5P1Sr3JnoRk=";
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
