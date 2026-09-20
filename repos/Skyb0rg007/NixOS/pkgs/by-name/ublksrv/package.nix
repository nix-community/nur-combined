{
  lib,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  liburing,
  testers,
  autoreconfHook,
  validatePkgConfig,
  # versionCheckHook,
  libnfs,
  libiscsi,
  gnutls,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ublksrv";
  version = "1.8";

  src = fetchFromGitHub {
    owner = "ublk-org";
    repo = "ublksrv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nCC75UqOkKQWYh+NiH+Bm3CLLS7xnWUxfxEXla51DCk=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    liburing
    libnfs
    libiscsi
    gnutls
  ];

  configureFlags = [
    (lib.withFeature true "libnfs")
    (lib.withFeature true "libiscsi")
    (lib.withFeature true "gnutls")
  ];

  postPatch = ''
    echo "${finalAttrs.version}" > VERSION
  '';

  nativeInstallCheckInputs = [
    validatePkgConfig
    # versionCheckHook # requires ublk_drv module loaded
  ];
  doInstallCheck = true;

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "userspace block device driver";
    homepage = "https://github.com/ublk-org/ublksrv";
    mainProgram = "ublk";
    platforms = lib.platforms.linux;
    license = with lib.licenses; [
      (OR [
        mit
        gpl2Only
      ])
      (OR [
        mit
        lgpl21Only
      ])
      gpl2Only
    ];
    pkgConfigModules = [ "ublksrv" ];
    maintainers = [ lib.maintainers.skyesoss ];
  };
})
