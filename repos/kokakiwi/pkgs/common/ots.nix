{ fetchFromGitHub }:
rec {
  version = "1.17.1";

  src = fetchFromGitHub {
    owner = "Luzifer";
    repo = "ots";
    rev = "v${version}";
    hash = "sha256-FRjitKlH7Yf4XBawVkXjBimJyhoQsZ3CQ2yS48K54Ug=";
  };
}
