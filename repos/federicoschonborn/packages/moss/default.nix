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
  pname = "moss";
  version = "1.0.1";

  srcs = [
    (fetchFromGitHub {
      name = "moss";
      owner = "serpent-os";
      repo = "moss";
      rev = "v${version}";
      hash = "sha256-56qqO/DDNXH2skpi2u1wl7kmfx9RYD9sTZH6micn59c=";
    })

    (fetchFromGitHub {
      name = "libmoss";
      owner = "serpent-os";
      repo = "libmoss";
      rev = "v1.2.0";
      hash = "sha256-P7QUheCxwt7lTh3K1NEUas4TyojMrzTsNWj8UVQqkl0=";
    })
  ];

  sourceRoot = "moss";

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
    description = "The advanced system management tool from Serpent OS";
    homepage = "https://github.com/serpent-os/moss";
    license = with licenses; [
      zlib
      # libmoss
      boost
    ];
  };
}
