{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
  kernel,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "acpi-ec";
  version = "1.0.4";
  src = fetchFromGitHub {
    owner = "musikid";
    repo = "acpi_ec";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gDcEzZKtHMULtTtJSDTRH1W9otSB6IC0E6EBF9j6F7Q=";
  };
  sourceRoot = "source/src";
  hardeningDisable = [
    "pic"
    "format"
  ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  KSRC = "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build";
  INSTALL_MOD_PATH = placeholder "out";

  makeFlags = kernel.commonMakeFlags or kernel.makeFlags;
  preBuild = ''
    makeFlags="$makeFlags -C ${finalAttrs.KSRC} M=$(pwd)"
  '';
  installTargets = [ "modules_install" ];

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/musikid/acpi_ec/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Kernel module to access directly to the ACPI EC";
    homepage = "https://github.com/musikid/acpi_ec";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
  };
})
