{
  lib,
  rustPlatform,
  fetchFromGitHub,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hledger-fmt";
  version = "0.2.11";

  src = fetchFromGitHub {
    owner = "mondeja";
    repo = "hledger-fmt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ukBevdprAKjdqr0R/3HBf98JkXnqNdBeAlHx8/QZ9Hg=";
  };

  cargoHash = "sha256-iEZM5xpszNe5Graxb5Po/hfEh0KGZuula/36UuNwezY=";

  # panics with "CLI not built. Run `cargo build` to build the hledger-fmt debug executable!"
  doCheck = false;

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "An opinionated hledger's journal files formatter";
    homepage = "https://github.com/mondeja/hledger-fmt";
    changelog = "https://github.com/mondeja/hledger-fmt/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "hledger-fmt";
  };
})
