{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  makeWrapper,
  makePythonPath,
  pythonOlder,
  indexed-bzip2,
  indexed-gzip,
  indexed-zstd,
  python-xz,
  rapidgzip,
  rarfile,
  zstandard,
  fsspec,
  libarchive-c,
  mfusepy,
  lrzip,
  lzop,
  lzmaffi,
  pysquashfsimage,
  py7zr,
  pyfatfs,
  python-ext4,
  sqlcipher3,
  cryptography,
}:

buildPythonPackage rec {
  pname = "ratarmountcore";
  version = "1.1.1";

  disabled = pythonOlder "3.6";

  src = fetchFromGitHub {
    owner = "mxmlnkn";
    repo = "ratarmount";
    tag = "v${version}";
    hash = "sha256-OEp2YV4PNRaFF5Al66+0KW842KlUWf+Dp2FmbrPLyug=";
    fetchSubmodules = true;
  };

  sourceRoot = "${src.name}/core";

  # NOTE here we add only python dependencies
  # so the user is responsible for adding native dependencies
  # see also nativeTestInputs in pkgs/development/python-modules/ratarmount/test.nix
  propagatedBuildInputs = [
    indexed-gzip
    indexed-bzip2
    indexed-zstd
    python-xz
    rapidgzip
    rarfile
    zstandard
    fsspec
    libarchive-c
    mfusepy
    lzmaffi
    pysquashfsimage
    py7zr
    pyfatfs
    python-ext4
    sqlcipher3
    cryptography # also required for sqlcipher3
  ];

  pythonImportsCheck = [ "ratarmountcore" ];

  meta = with lib; {
    description = "Library for accessing archives by way of indexing";
    homepage = "https://github.com/mxmlnkn/ratarmount/tree/master/core";
    license = licenses.mit;
    maintainers = with lib.maintainers; [ mxmlnkn ];
    platforms = platforms.all;
  };
}
