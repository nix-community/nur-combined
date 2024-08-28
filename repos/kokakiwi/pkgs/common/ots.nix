{ fetchFromGitHub }:
rec {
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-+ntR5yOvX7fG7YGrLKCjNYfkxCChQ0yOB6JuVSraRZM=";
  };
}
