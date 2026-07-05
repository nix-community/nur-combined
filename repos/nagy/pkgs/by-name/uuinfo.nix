{
  lib,
  rustPlatform,
  fetchFromGitHub,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uuinfo";
  version = "0.7.5";
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "Racum";
    repo = "uuinfo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OUR5siS6uQcZL1HyJVdAB5WZ86jf8eVj22N6UJtx8oc=";
  };

  cargoHash = "sha256-lA0gLTh00yYmuqyYNI3o8021JmuNlRczIeVU1Sl8aGM=";

  # Integration tests hardcode target/debug/uuinfo but Nix builds in release mode
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A tool to debug unique identifiers (UUID, ULID, Snowflake, etc";
    homepage = "https://github.com/Racum/uuinfo";
    changelog = "https://github.com/Racum/uuinfo/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "uuinfo";
  };
})
