{
  mkCutefishDerivation,
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

mkCutefishDerivation {
  pname = "cutefish-filemanager";

  extraBuildInputs = [
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

  meta = {
    description = "File manager for the Cutefish desktop; also draws the desktop icons";
    mainProgram = "cutefish-filemanager";
  };
}
