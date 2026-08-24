{
  fetchzip,
  klknn,
  nix-update-script,
}:
klknn.mkKlknn rec {
  pname = "envtool-bin";
  version = "1.5.1";
  src = fetchzip {
    url = "https://github.com/klknn/kdr/releases/download/v${version}/ubuntu-latest-envtool.zip";
    hash = "sha256-5DjlkYjUUrY8pPr5lsWFtFxsjiGkiXZIZE1+GRH9jJ0=";
  };
}
