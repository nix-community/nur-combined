{
  sources,
  version,
  lib,
  stdenv,
  autoreconfHook,
  pkg-config,
  libgcrypt,
  gnutls,
  gettext,
  gitUpdater,
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

  buildInputs = [
    libgcrypt
    gnutls
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isGnu) [ gettext ];

  configureFlags = [ "--exec-prefix=\${prefix}" ];

  enableParallelBuilding = true;

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "NTFS filesystem userspace utilities";
    homepage = "https://github.com/ntfsprogs-plus/ntfsprogs-plus";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    platforms = lib.platforms.unix;
  };
}
