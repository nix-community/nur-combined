{
  sources,
  version,
  lib,
  stdenv,
  autoreconfHook,
  pkg-config,
  libgcrypt,
}:
stdenv.mkDerivation {
  inherit (sources) pname src;
  inherit version;

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libgcrypt ];

  configureFlags = [ "--exec-prefix=\${prefix}" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "NTFS filesystem userspace utilities ";
    homepage = "https://github.com/ntfsprogs-plus/ntfsprogs-plus";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ccicnce113424 ];
    platforms = platforms.linux;
  };
}
