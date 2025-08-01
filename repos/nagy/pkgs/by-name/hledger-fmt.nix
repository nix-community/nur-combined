{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hledger-fmt";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "mondeja";
    repo = "hledger-fmt";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ox/kWMTleurjVZEgw7EOg/PICkZMr+1FNpdDa4KnSOQ=";
  };

  cargoHash = "sha256-PyMlwdIBUyv28UPf/ku4TfPGHQVN8aQ6hUyJbLX/SRc=";

  meta = {
    description = "An opinionated hledger's journal files formatter";
    homepage = "https://github.com/mondeja/hledger-fmt";
    changelog = "https://github.com/mondeja/hledger-fmt/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nagy ];
    mainProgram = "hledger-fmt";
  };
})
