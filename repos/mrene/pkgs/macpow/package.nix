{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "macpow";
  version = "0.1.17";

  src = fetchFromGitHub {
    owner = "k06a";
    repo = "macpow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lIEjmafzc55uaFQa1mjJH466s10ckF2IW80i8g1Tl9I=";
  };

  cargoHash = "sha256-rRiHGiyUSQomJLhMODzhoNIDWzZP6nO3diYFTeB59sQ=";

  meta = {
    description = "Real-time power tree TUI for Apple Silicon";
    homepage = "https://github.com/k06a/macpow";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "macpow";
  };
})
