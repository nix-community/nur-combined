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
  versionCheckHook,
  coreutils,
  libnfs,
  libiscsi,
  gnutls,
  nixosTests,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ublksrv";
  version = "1.8-unstable-2026-09-24";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "ublk-org";
    repo = "ublksrv";
    # tag = "v${finalAttrs.version}";
    rev = "e36fae3f0995c4940b9007eb10d020beaba6a7e2";
    hash = "sha256-hg4ioxUqO+6Z2JxEXewUMg4x0a7jdxTOWXpQP9QiwRc=";
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
    versionCheckHook
  ];
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
      nixos = nixosTests.ublksrv;
    };
  };

  meta = {
    description = "userspace block device driver";
    homepage = "https://github.com/ublk-org/ublksrv";
    mainProgram = "ublk";
    platforms = lib.platforms.linux;
    license =
      with lib.licenses;
      AND [
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
