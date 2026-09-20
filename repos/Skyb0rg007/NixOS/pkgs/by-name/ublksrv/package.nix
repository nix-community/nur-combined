{
  lib,
  fetchFromGitHub,
  stdenv,
  pkg-config,
  liburing,
  testers,
  autoreconfHook,
  validatePkgConfig,
  udevCheckHook,
  # versionCheckHook,
  coreutils,
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

  postInstall = ''
    mkdir -p $out/libexec $out/lib/udev/rules.d

    mv $out/sbin/ublk_{chown{,_docker}.sh,user_id} $out/libexec
    substituteInPlace $out/libexec/ublk_chown{,_docker}.sh \
      --replace-fail /usr/bin/chown ${lib.getExe' coreutils "chown"}

    install -m644 -t $out/lib/udev/rules.d utils/ublk_dev.rules
    substituteInPlace $out/lib/udev/rules.d/ublk_dev.rules \
      --replace-fail /usr/local/sbin/ublk_chown.sh $out/libexec/ublk_chown.sh
  '';

  nativeInstallCheckInputs = [
    validatePkgConfig
    udevCheckHook
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
