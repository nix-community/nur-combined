{
  stdenv,
  lib,
  sources,
  kernel,
}:
stdenv.mkDerivation rec {
  pname = "xt_rtpengine";
  inherit (sources.rtpengine) version src;
  sourceRoot = "source/kernel-module";

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "depmod -a" "# depmod -a"
  '';

  makeFlags =
    (if lib.hasAttr "moduleMakeFlags" kernel then kernel.moduleMakeFlags else kernel.makeFlags)
    ++ [
      "DESTDIR=${placeholder "out"}"
    ];

  meta = {
    changelog = "https://github.com/sipwise/rtpengine/releases/tag/v${version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Sipwise media proxy for Kamailio (kernel module)";
    homepage = "https://github.com/sipwise/rtpengine";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
}
