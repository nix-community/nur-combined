{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ht";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "andyk";
    repo = "ht";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LKa5nnGhQITf0SDzE17NUJ9KQ6Soq6jOBWoTONRxiCc=";
  };

  cargoHash = "sha256-FlR7bvQAZZIJaONOGsZUtSuUOvAVeDXJQaEkvXYxp1w=";

  meta = {
    description = "Headless terminal - wrap any binary with a terminal interface for easy programmatic access";
    homepage = "https://github.com/andyk/ht";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "ht";
  };
})
