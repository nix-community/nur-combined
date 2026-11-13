{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xt_rtpengine";
  version = "0-unstable-2026-11-12";
  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "rtpengine";
    rev = "432d5ddd1a8c77b81823c0a8fbb061c198abed71";
    hash = "sha256-BCROaWzUPnLkorFyo8pkj8jOHwW4HnRZx50FtU9CcPA=";
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

  installFlags = [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];
  installTargets = [ "modules_install" ];

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
