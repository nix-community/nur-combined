{
  fetchzip,
  klknn,
}:
klknn.mkKlknn rec {
  pname = "synth2-bin";
  version = "1.5.1";
  src = fetchzip {
    url = "https://github.com/klknn/kdr/releases/download/v${version}/ubuntu-latest-synth2.zip";
    hash = "sha256-8Qz5lUN+UhK/eyVynHwf8zGekFAvrhF2bwEqH7NtH2I=";
  };
}
