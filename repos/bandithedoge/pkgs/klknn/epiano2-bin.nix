{
  fetchzip,
  klknn,
}:
klknn.mkKlknn rec {
  pname = "epiano2-bin";
  version = "1.5.1";
  src = fetchzip {
    url = "https://github.com/klknn/kdr/releases/download/v${version}/ubuntu-latest-epiano2.zip";
    hash = "sha256-o0EhmjMOgpfX2+PUKjP6LgB49DMdC58ndouAqg+7Qbk=";
  };
}
