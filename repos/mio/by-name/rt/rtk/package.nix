{
  lib,
  fetchFromGitHub,
  rustPlatform,
  sqlite,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rtk";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "v${finalAttrs.version}";
    hash = "sha256-sfx7rfoiXgnaqW0Gq5fiQqKY2NsSO7rwmxWxqTgkzbQ=";
  };

  cargoHash = "sha256-X1TkZyG/aYEhUeQmpxEG/rXi1iUCFkxSNc7iD1ZGCy8=";

  # rusqlite links sqlite3 by name on darwin.
  buildInputs = [ sqlite ];

  # Tests spawn the freshly built CLI and touch the user's tool configuration.
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rust Token Killer — CLI proxy that minimizes LLM token consumption";
    homepage = "https://github.com/rtk-ai/rtk";
    changelog = "https://github.com/rtk-ai/rtk/blob/v${finalAttrs.version}/CHANGELOG.md";
    # The CLI is Apache-2.0 but links rtk-engine, which is BUSL-1.1.
    license = with lib.licenses; [
      asl20
      bsl11
    ];
    mainProgram = "rtk";
    platforms = lib.platforms.unix;
  };
})
