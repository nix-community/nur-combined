{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "snapshotfs";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-SAq2IH3N9yYbhlo/hYrUU0472rlgVGr4K2iMRuc0tIo=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ZBmQuD7Sc3mt5nQGAVq99PohBKlWm2ToDbXW7xoLv44=";

  meta = with lib; {
    description = "A fuse-based read-only filesystem to provide a snapshot view (tar archives) of directories or files without actually creating the archives";
    homepage = "https://github.com/DCsunset/snapshotfs";
    license = licenses.agpl3Only;
  };
}
