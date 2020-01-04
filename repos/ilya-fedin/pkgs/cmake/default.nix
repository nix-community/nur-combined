{ lib, fetchurl, fetchpatch, cmake }:

cmake.overrideAttrs(oldAttrs: rec {
  version = "3.16.2";

  src = fetchurl {
    url = "${oldAttrs.meta.homepage}files/v${lib.versions.majorMinor version}/cmake-${version}.tar.gz";
    # compare with https://cmake.org/files/v${lib.versions.majorMinor version}/cmake-${version}-SHA-256.txt
    sha256 = "1ag65ignli58kpmji6gjhj8xw4w1qdr910i99hsvx8hcqrp7h2cc";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/NixOS/nixpkgs/raw/ec9cf578e56ff7c3045878f86506338b0112777d/pkgs/development/tools/build-managers/cmake/search-path.patch";
      sha256 = "1rp06l97g4pixb1rfygf3s7aaz9hjjyp2lkrjp1rvpwha108001d";
    })

    ./application-services.patch
    ./libuv-application-services.patch
  ];
})