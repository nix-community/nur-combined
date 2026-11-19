{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "xt_rtpengine";
  version = "0-unstable-2026-11-18";
  src = fetchFromGitHub {
    owner = "sipwise";
    repo = "rtpengine";
    rev = "c293f3e55ad7c19afaca7cb399cf58664ad0e581";
    hash = "sha256-Ap4KjN8+KS3JRsw0kPou3ktlU7O4AhIL14eIPl8Tkcw=";
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
