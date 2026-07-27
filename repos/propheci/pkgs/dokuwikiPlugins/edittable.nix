{ stdenv, fetchzip, ... }:
stdenv.mkDerivation rec {
  name = "edittable";
  version = "2023-01-14";

  src = fetchzip {
    url = "https://github.com/cosmocode/edittable/archive/refs/tags/${version}.zip";
    hash = "sha256-Mns8zgucpJrg1xdEopAhd4q1KH7j83Mz3wxuu4Thgsg=";
  };
  installPhase = "mkdir -p $out; cp -R * $out/";
}
