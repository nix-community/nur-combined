{ lib
, fetchFromGitHub
, rustPlatform
, installShellFiles
}:

rustPlatform.buildRustPackage rec {
  pname = "prosemd-lsp";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "kitten";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FnAf7+1tDho0Fbhsd6XXxnNADVwEwY13rXjrUbGqLdQ=";
  };

  cargoSha256 = "sha256-1KE84o/KDkDMwlxqeDQmniBL6mDE1RSWG5J8nTvBwa4=";

  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://github.com/kitten/prosemd-lsp";
    description = "An experimental proofreading and linting language server for markdown files";
    license = licenses.lgpl21;
  };
}
