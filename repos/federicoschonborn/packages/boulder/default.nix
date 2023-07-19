{ lib
, stdenv
, fetchFromGitHub
, curl
, ldc
, lmdb
, meson
, ninja
, pkg-config
, xxHash
, zstd
}:

stdenv.mkDerivation rec {
  pname = "boulder";
  version = "1.0.1";

  srcs = [
    (fetchFromGitHub {
      name = "boulder";
      owner = "serpent-os";
      repo = "boulder";
      rev = "v${version}";
      hash = "sha256-FBacbTvU9diD+kK0x1KzSVw6xcbOeVytsmDQBv1QZ0w=";
    })

    (fetchFromGitHub {
      name = "libmoss";
      owner = "serpent-os";
      repo = "libmoss";
      rev = "v1.2.0";
      hash = "sha256-P7QUheCxwt7lTh3K1NEUas4TyojMrzTsNWj8UVQqkl0=";
    })
  ];

  sourceRoot = "boulder";

  nativeBuildInputs = [
    ldc
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    curl
    lmdb
    xxHash
    zstd
  ];

  meta = with lib; {
    description = "Serpent OS Build Tool";
    homepage = "https://github.com/serpent-os/boulder";
    license = with licenses; [ zlib ];
  };
}
