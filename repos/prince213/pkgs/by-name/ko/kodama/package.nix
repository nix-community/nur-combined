{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "1.2.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kodama-community";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-je8KjRkkOGp0+NCNsyc2Ngr1o0DsYs+AFT+8beZWdKE=";
  };

  cargoHash = "sha256-gzod0nZOcnr+HL70wP6BIgcjL5uB988o09HehQD26nA=";

  # flaky
  checkFlags = [
    "--skip=cli::upgrade_hint::tests::test_check_outdated_with_hints_once_per_file_state"
  ];

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kodama-community/kodama";
    downloadPage = "https://github.com/kodama-community/kodama/releases";
    changelog = "https://github.com/kodama-community/kodama/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
