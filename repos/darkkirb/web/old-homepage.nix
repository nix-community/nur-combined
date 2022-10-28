{
  fetchzip,
  zstd,
}:
fetchzip {
  url = "https://static.darkkirb.de/homepage.tar.zst";
  sha256 = "sha256-T9fiDZSaAO9+YljPgQM7vEtJcs0tQF2Bd0BlsO4EyfE=";
  nativeBuildInputs = [zstd];
}
