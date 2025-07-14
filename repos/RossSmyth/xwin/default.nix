{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xwin";
  version = "0.6.6";

  src = fetchFromGitHub {
    owner = "Jake-Shadle";
    repo = "xwin";
    rev = finalAttrs.version;
    hash = "sha256-bow/TJ6aIXoNZDqCTlQYAMxEUiolby1axsKiLMk/jiA=";
  };

  cargoHash = "sha256-S/3EjlG0Dr/KKAYSFaX/aFh/CIc19Bv+rKYzKPWC+MI=";

  # Tests access the network
  doCheck = true;
  checkFlags = [
    "--skip verify_compiles"
    "--skip verify_deterministic"
  ];

  meta = {
    description = "utility for downloading and packaging the Microsoft CRT & Windows SDK headers and libraries";
    homepage = "https://github.com/Jake-Shadle/xwin";
    changelog = "https://github.com/Jake-Shadle/xwin/releases/tag/" + finalAttrs.version;
    license = [
      lib.licenses.mit
      lib.licenses.apsl10
    ];
  };
})
