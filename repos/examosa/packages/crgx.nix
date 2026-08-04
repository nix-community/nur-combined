{
  fetchFromGitHub,
  lib,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "crgx";
  version = "0.1.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "yfedoseev";
    repo = "crgx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eKtiB+7U2daUpN31axxAHswZE6xQ2mh09mMhdCr1Suc=";
  };

  cargoHash = "sha256-qwwI2nUub0wkBwny0IsKXTDNrsq5WPR5x1v55nJwx1Y=";

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Npx for Rust — run any crate binary instantly without cargo install";
    homepage = "https://github.com/yfedoseev/crgx";
    changelog = "https://github.com/yfedoseev/crgx/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "crgx";
  };
})
