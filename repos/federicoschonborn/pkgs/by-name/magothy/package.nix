{
  lib,
  rustPlatform,
  fetchFromGitea,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-03-10";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "98f32d47ec7487a4ea43f342bf395eff63cd3823";
    hash = "sha256-9i35Uu8KEACEESiH+v9zPT2nZykvCjP5hL9l87C5zHM=";
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
