{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "myx";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "HaseebKhalid1507";
    repo = "Myx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qSOpK+k1Rw7yJvMhaG4LbG7bfTtkuBw6BCzN9UkGrGY=";
  };

  cargoHash = "sha256-InX9HtZI686ukKLfLp4qOOWGg6DdKVMv8LsBOYf8M+c=";

  nativeBuildInputs = [pkg-config];

  buildInputs = [
    alsa-lib
    openssl
  ];

  meta = {
    description = "Lean, beautiful terminal Spotify player";
    homepage = "https://github.com/HaseebKhalid1507/Myx";
    changelog = "https://github.com/HaseebKhalid1507/Myx/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    maintainers = [
      {
        name = "Hadi";
        github = "anotherhadi";
        githubId = 112569860;
      }
    ];
    mainProgram = "myx";
  };
})
