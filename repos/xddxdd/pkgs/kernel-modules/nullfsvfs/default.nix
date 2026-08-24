{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "nullfsvfs";
  version = "0.27";
  src = fetchFromGitHub {
    owner = "abbbi";
    repo = "nullfsvfs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BvixSZN9GqFS4llaiKHfkLb21+qG74YtyNb8bUP0jdU=";
  };
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  patches = [ ./nullfsvfs-change-reported-free-space.patch ];

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${finalAttrs.KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/abbbi/nullfsvfs/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Virtual black hole file system that behaves like /dev/null";
    homepage = "https://github.com/abbbi/nullfsvfs";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
