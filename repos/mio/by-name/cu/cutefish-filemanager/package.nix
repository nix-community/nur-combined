{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  cutefish-toolkit,
  cutefish-framework,
  icu,
  fuse3,
  libssh,
  samba,
  libmtp,
  systemd,
  zlib,
  bzip2,
  xz,
  lzfse,
  libzip,
  libarchive,
}:

let
  cu = import ../cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "cutefish-filemanager";
  version = cu.version "2026-10-23";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "filemanager";
    rev = "e3dfa655d51b7861a10d84c694e4cc0af943f48e";
    hash = "sha256-JMc8OFnq+f2LPTMHxvNhcx2W+vx0xWCrYVPZsCFHwbw=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    cutefish-framework
    icu
    fuse3
    libssh
    samba
    libmtp
    systemd
    zlib
    bzip2
    xz
    lzfse
    libzip
    libarchive
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "File manager for the Cutefish desktop; also draws the desktop icons";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-filemanager";
  };
}
