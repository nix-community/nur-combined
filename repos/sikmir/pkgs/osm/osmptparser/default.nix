{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "osmptparser";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "cualbondi";
    repo = "osmptparser";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/Uokg1CPn/ut2k0u/QCBAFECOctgHkUZMVMgcvkDYnw=";
  };

  cargoHash = "sha256-UXYcoBwChSEofyQWpZPp5GTVMA2xft1DY0WefSSOV2c=";

  doCheck = false;

  meta = {
    description = "Open Street Map Public Transport Parser";
    homepage = "https://github.com/cualbondi/osmptparser";
    license = lib.licenses.agpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "osmptparser";
  };
})
