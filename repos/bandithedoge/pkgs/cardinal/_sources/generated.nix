# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}: {
  cardinal = {
    pname = "cardinal";
    version = "89a18eb2f8af0c78bd60d621718fcec10c0327fb";
    src = fetchFromGitHub {
      owner = "DISTRHO";
      repo = "Cardinal";
      rev = "89a18eb2f8af0c78bd60d621718fcec10c0327fb";
      fetchSubmodules = true;
      sha256 = "sha256-pZvVe2T+7+8MAkiBFmoXoTFKKQmlnOuBFn8eubo3UFc=";
    };
    date = "2025-01-08";
  };
}
