{
  fetchFromGitHub,
  unstableGitUpdater,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nft-fullcone";
  version = "0-unstable-2023-05-17";
  src = fetchFromGitHub {
    owner = "fullcone-nat-nftables";
    repo = "nft-fullcone";
    rev = "07d93b626ce5ea885cd16f9ab07fac3213c355d9";
    hash = "sha256-PJHKt7w72lYFAb2OSswX7QyLnSY0jB93DkBxGk8AwD4=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  sourceRoot = "source/src";

  patches = [ ./nft-fullcone.patch ];

  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  env.KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  env.INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlagsArray+=("-C" "${finalAttrs.env.KSRC}" "M=$(pwd)")
  '';
  installTargets = [ "modules_install" ];

  passthru.updateScript = unstableGitUpdater {
    url = "https://github.com/fullcone-nat-nftables/nft-fullcone";
    hardcodeZeroVersion = true;
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Nftables fullcone expression kernel module";
    homepage = "https://github.com/fullcone-nat-nftables/nft-fullcone";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
