{
  fetchzip,
  klknn,
}:
klknn.mkKlknn rec {
  pname = "freeverb-bin";
  version = "1.5.1";
  src = fetchzip {
    url = "https://github.com/klknn/kdr/releases/download/v${version}/ubuntu-latest-freeverb.zip";
    hash = "sha256-KzqqJdXGXdbsU0A0evOvkqz9ImF+IyoC4vtdbTqGqQU=";
  };
}
