{ stdenv, lib, fetchFromGitHub
, cmake, pkg-config
, libevdev, libudev }:

stdenv.mkDerivation {
  pname = "joycond";
  version = "unstable-2021-03-06";

  src = fetchFromGitHub {
    owner = "DanielOgorchock";
    repo = "joycond";
    rev = "3add2fb384ad9966acb5aed2121328be23f354e9";
    hash = "sha256:05ca9332nrx5b84f0kv3hmfkfdip5wc04fyy163v5i8gjky23hh6";
  };

  patches = [
    ./install-locations.patch
    ./service.patch
  ];

  postPatch = ''
    substituteAllInPlace systemd/joycond.service
  '';

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = [ libevdev libudev ];

  meta = {
    description = "Userspace daemon to combine joy-cons from the hid-nintendo kernel driver";
    license = lib.licenses.gpl3Only;
  };
}
