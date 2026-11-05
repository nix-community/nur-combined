{
  fetchFromGitHub,
  glibc,
  lib,
  nix-update-script,
  rustPlatform,
  stdenv,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "crgx";
  version = "0.1.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "yfedoseev";
    repo = "crgx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rBzKY3owlk9SDFZSFv7tg2xPGUpUFLafxmaFW0+IS5E=";
  };

  cargoHash = "sha256-3RuHgz9xfpi4eLqNQuDItRUipN2CxbhVioTANRekTs0=";

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace src/config.rs \
      --replace-fail '"/lib"' '"${lib.makeLibraryPath [glibc]}"'
  '';

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    description = "Npx for Rust — run any crate binary instantly without cargo install";
    homepage = "https://github.com/yfedoseev/crgx";
    changelog = "https://github.com/yfedoseev/crgx/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "crgx";
    maintainers = [lib.maintainers.examosa];
    platforms = lib.platforms.all;
  };
})
