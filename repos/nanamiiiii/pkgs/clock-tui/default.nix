{
  lib,
  fetchFromGitHub,
  rustPlatform,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "clock-tui";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "race604";
    repo = "clock-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IsJxKCR3yBuwv33FYfHF+Xuu8zgu4mxx3RBnxJkR4rI=";
  };

  cargoHash = "sha256-u3sRuZVLOqbCmhDXRHjInr9AQE3pnOHU0vFITb7N6Yk=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A clock app in terminal written in Rust, supports local clock, timer and stopwatch.";
    homepage = "https://github.com/race604/clock-tui";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
