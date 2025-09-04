{
  lib,
  rustPlatform,
  fetchFromGitHub,
  libdrm,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cyan-skillfish-governor";
  version = "0.1.3";
  src = fetchFromGitHub {
    owner = "Magnap";
    repo = "cyan-skillfish-governor";
    tag = "v" + finalAttrs.version;
    hash = "sha256-EJhgk3ixZvLsZ9rbQ7LDJtx3K8K/qEraDwBrkOtHPuk=";
  };
  cargoHash = "sha256-Lg7ZPDqLd+6X0VSIIYQg1m8Q+rnL5LEPa8C2LZAPbhA=";
  buildInputs = [ libdrm ];
  meta = {
    description = "Cyan Skillfish GPU governor";
    homepage = "https://github.com/Magnap/cyan-skillfish-governor";
    license = lib.licenses.mit;
    mainProgram = "cyan-skillfish-governor";
    platforms = lib.platforms.linux;
  };
})
