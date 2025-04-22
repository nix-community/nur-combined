{
  lib,
  stdenv,
  fetchFromGitHub,
  libtool,
  autoconf,
  automake,
  fuse,
  libnfs,
}:

stdenv.mkDerivation rec {
  pname = "fuse-nfs";
  version = "unstable-2022-12-09";

  src = fetchFromGitHub {
    owner = "sahlberg";
    repo = "fuse-nfs";
    rev = "331e6fe5ea39d2353bbbe85e87b5850e4b144d9f";
    hash = "sha256-YPBPH1PMHAiuHV8DtZNJVZ8VP4YeZ357ZTA2XOP/rA8=";
  };

  nativeBuildInputs = [
    libtool
    autoconf
    automake
  ];

  buildInputs = [
    fuse
    libnfs
  ];

  preConfigure = ''
    ./setup.sh
  '';

  meta = with lib; {
    description = "A FUSE module for NFSv3/4";
    homepage = "https://github.com/sahlberg/fuse-nfs";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "fuse-nfs";
    platforms = platforms.all;
  };
}
