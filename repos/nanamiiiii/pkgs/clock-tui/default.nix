{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage rec {
  pname = "clock-tui";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "race604";
    repo = "clock-tui";
    tag = "v${version}";
    hash = "sha256-GuxE50rP+NOzeoFljmBTCp23LCuu6mz2HNL/eEf5ZJE=";
  };

  cargoHash = "sha256-wbkWO2UqE7ymmb6RyV7G1J1GjgSr0lbhzc7pFi6/ajo=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A clock app in terminal written in Rust, supports local clock, timer and stopwatch.";
    homepage = "https://github.com/race604/clock-tui";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
