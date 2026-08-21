{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kodama";
  version = "1.1.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "kodama-community";
    repo = "kodama";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M1m7kfmiA4LyLIKihz+2CV72fqdq1mh4p2mMlWJnhMw=";
  };

  cargoHash = "sha256-DUa/LYp+N7NSdaCR0bhc0oDvb17WMkOz2awjAvFV3qg=";

  meta = {
    description = "Typst-friendly static Zettelkästen site generator";
    homepage = "https://github.com/kodama-community/kodama";
    downloadPage = "https://github.com/kodama-community/kodama/releases";
    changelog = "https://github.com/kodama-community/kodama/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
