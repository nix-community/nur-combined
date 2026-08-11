{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "parsec-tool";
  version = "0.7.0";
  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "parallaxsecond";
    repo = "parsec-tool";
    tag = finalAttrs.version;
    hash = "sha256-hUZUbpTRq088OgVs0hp3UqwA0tWN/xyTsdCVzMFBGKg=";
  };

  cargoHash = "sha256-U79tTTj31LmuLyafNcuaYM2pRoSo3mx4AudD9fefYg8=";

  meta = {
    description = "Parsec Command Line Interface";
    homepage = "https://parsec.community";
    changelog = "https://github.com/parallaxsecond/parsec-tool/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.skyesoss ];
    mainProgram = "parsec-tool";
    platforms = lib.platforms.linux;
  };
})
