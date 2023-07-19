{ lib
, stdenv
, fetchFromGitHub
, libmossSrc
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

    libmossSrc
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
