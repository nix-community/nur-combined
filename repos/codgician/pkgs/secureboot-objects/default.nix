{
  lib,
  stdenvNoCC,
  fetchurl,
  runCommand,
}:

let
  pname = "secureboot-objects";
  version = "1.7.0";
  baseUrl = "https://github.com/microsoft/secureboot_objects/releases/download/v${version}-signed";
  # The authenticated updates must retain Microsoft's KEK signatures;
  # rebuilding the source cannot produce equivalent usable firmware objects.
  # Upstream ships three signed archives as of v1.7.0:
  #   - edk2-2011: hash revocations signed by Microsoft UEFI CA 2011
  #   - edk2-2023: same revocations signed by Microsoft Corporation KEK CA 2023
  #   - edk2-2011-optional: optional DB/DBX transitions (2011 KEK)
  sources = {
    signed2011 = {
      url = "${baseUrl}/edk2-2011-signed-secureboot-binaries.tar.gz";
      hash = "sha256-kox3MafkMU7xmKI1Fpz72rsYS3nBozPPjWrqrn3CVj4=";
    };
    signed2023 = {
      url = "${baseUrl}/edk2-2023-signed-secureboot-binaries.tar.gz";
      hash = "sha256-MEdX2g/M/pwVRGyaSc5sDwzDYqFLvusQOC0qP4fbfWI=";
    };
    optional = {
      url = "${baseUrl}/edk2-2011-optional-signed-secureboot-binaries.tar.gz";
      hash = "sha256-9ar8H1rP6RY14JnigeYiabFA+4A3Emk9yrlqgR3fWzU=";
    };
  };
  signed2011Src = fetchurl sources.signed2011;
  signed2023Src = fetchurl sources.signed2023;
  optionalSrc = fetchurl sources.optional;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install_dir="$out/share/${pname}"
    mkdir -p \
      "$install_dir/edk2-2011" \
      "$install_dir/edk2-2023" \
      "$install_dir/edk2-2011-optional"

    # Archives are tiny multi-arch firmware objects; install every architecture
    # so the package can service systems other than the build host.
    tar --extract --gzip --file ${signed2011Src} --directory "$install_dir/edk2-2011"
    tar --extract --gzip --file ${signed2023Src} --directory "$install_dir/edk2-2023"
    tar --extract --gzip --file ${optionalSrc} --directory "$install_dir/edk2-2011-optional"

    runHook postInstall
  '';

  passthru = {
    # nix-update-script's custom dependencies require outputHash and reject
    # this fetchurl source; gitUpdater cannot hash the companion tarballs.
    # update.sh therefore refreshes every release-asset hash together.
    updateScript = ./update.sh;
    tests.smoke = runCommand "${pname}-smoke" { } ''
      root=${finalAttrs.finalPackage}/share/${pname}
      test -s "$root/edk2-2011/dbx_x64_Legacy/dbx_x64_Legacy.efiauth2"
      test -s "$root/edk2-2011/dbx_aarch64_Legacy/dbx_aarch64_Legacy.efiauth2"
      test -s "$root/edk2-2023/dbx_x64.efiauth2"
      test -s "$root/edk2-2023/dbx_aarch64.efiauth2"
      test -s "$root/edk2-2011-optional/DB/DBUpdate2024.bin"
      test -s "$root/edk2-2011-optional/DBX/DBXUpdate2024.bin"
      test -s "$root/edk2-2011/version"
      touch "$out"
    '';
  };

  meta = {
    description = "Secure Boot objects recommended by Microsoft";
    homepage = "https://github.com/microsoft/secureboot_objects";
    changelog = "https://github.com/microsoft/secureboot_objects/releases/tag/v${version}-signed";
    license = lib.licenses.bsd2Patent;
    sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ codgician ];
  };
})
