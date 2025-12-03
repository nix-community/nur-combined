{
  curl,
  fuse,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  name = "curlftprs";
  src = ./.;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    curl
    fuse
  ];

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "mount a remote FTP endpoint onto the local filesystem";
    longDescription = ''
      spiritual successor to `curlftpfs`.
      built on top of curl (via curl-rust bindings) and fuse (via fuser rust-native implementation).
      special care is taken to ensure reasonable behavior even under adverse network conditions,
      i.e. curlftprs won't hang your system if your FTP server becomes unreachable or unresponsive.
    '';
  };
}
