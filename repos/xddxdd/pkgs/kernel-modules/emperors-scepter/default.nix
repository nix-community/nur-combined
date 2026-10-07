{
  stdenv,
  lib,
  pkgs,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "emperors-scepter";
  version = "0.1.0-${kernel.version}";

  src = ./src;
  __structuredAttrs = true;
  strictDeps = true;

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
  '';
  installTargets = [ "modules_install" ];

  passthru.tests.vm = pkgs.testers.runNixOSTest ./test.nix;

  meta = {
    description = "Idle kthreads for the twelve Scepter δ-me13 signals";
    homepage = "https://honkai-star-rail.fandom.com/wiki/As_I%27ve_Written/%CE%B4-me13.exe";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ xddxdd ];
    platforms = lib.platforms.linux;
  };
})
