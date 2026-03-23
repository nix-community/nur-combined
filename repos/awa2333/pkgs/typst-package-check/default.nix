{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "package-check";
  version = "0.4.5-1";
  src = fetchFromGitHub {
    owner = "typst";
    repo = "package-check";
    tag = "v${finalAttrs.version}";
    hash = "sha256-F6LBm7CzZowxv5Uha3xD0Ai5jt3NLVW+cmvIkNf+AIQ=";
  };
  cargoHash = "sha256-s8e3Zxp29RuZTmjXqQUMCyyQF0TJRCj6j2FEIMOk+xM=";
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [
    openssl
  ];
  meta = {
    description = "A tool to check Typst packages";
    homepage = "https://github.com/typst/package-check";
    license = lib.licenses.mit;
    mainProgram = "package-check";
    platforms = lib.platforms.all;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
