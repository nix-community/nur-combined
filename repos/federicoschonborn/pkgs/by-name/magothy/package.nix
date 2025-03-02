{
  lib,
  rustPlatform,
  fetchFromGitea,
  nix-update-script,
}:

rustPlatform.buildRustPackage {
  pname = "magothy";
  version = "0-unstable-2025-02-24";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "serebit";
    repo = "magothy";
    rev = "38d5df1fb4a9610bb02706f255551ed752738ee6";
    hash = "sha256-2Wl4cqlU2CP+knlCfjcUUdCgkvQlIoF5K+l1EX5D8go=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-LXlDv6gEY8HhyN7XNY9ioTD77o232yY3O/ZPjwBBKl4=";

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
