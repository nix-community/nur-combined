{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xt_rtpengine";
  version = "0-unstable-2026-10-23";
  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "rtpengine";
    rev = "b7cd0d62e1498dfd28b0d35c437459caa7da6c3f";
    hash = "sha256-0wqedZiLSxO40aqmKaNBzsJ+irLaEhfp5ap0rApPrw0=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  sourceRoot = "source/kernel-module";

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.INSTALL_MOD_PATH = placeholder "out";

  postPatch = ''
    patchShebangs .
    substituteInPlace Makefile \
      --replace-fail "depmod -a" "# depmod -a"
  '';

  makeFlags = (kernel.commonMakeFlags or kernel.makeFlags) ++ [
    "DESTDIR=${placeholder "out"}"
  ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/sipwise/rtpengine";
    tagPrefix = "mr";
    shallowClone = false;
  };
  meta = {
    changelog = "https://github.com/sipwise/rtpengine/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Sipwise media proxy for Kamailio (kernel module)";
    homepage = "https://github.com/sipwise/rtpengine";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
