{
  lib,
  stdenvNoCC,
  fetchurl,
  runCommand,
}:

let
  pname = "secureboot-objects";
  version = "1.6.5";
  architectures = {
    x86_64-linux = "amd64";
    i686-linux = "x86";
    aarch64-linux = "arm64";
    armv6l-linux = "arm";
    armv7l-linux = "arm";
  };
  architecture =
    architectures.${stdenvNoCC.hostPlatform.system}
      or (throw "${pname}: unsupported system ${stdenvNoCC.hostPlatform.system}");
  baseUrl = "https://github.com/microsoft/secureboot_objects/releases/download/v${version}-signed";
  # The authenticated updates must retain Microsoft's UEFI CA 2011 signature;
  # rebuilding the source cannot produce equivalent usable firmware objects.
  sources = {
    signed = {
      url = "${baseUrl}/edk2-2011-signed-secureboot-binaries.tar.gz";
      hash = "sha256-ST4AQxCEt/sGvt4uedjVtxpr44Ah7r9b2iAQjSfbVJQ=";
    };
    optional = {
      url = "${baseUrl}/edk2-2011-optional-signed-secureboot-binaries.tar.gz";
      hash = "sha256-kcIR42jO9cA6vF3mLuYsv+57NXvA2g9GBsmHXt7Ckfc=";
    };
  };
  optionalSrc = fetchurl sources.optional;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  src = fetchurl sources.signed;
  inherit optionalSrc;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install_dir="$out/share/${pname}"
    mkdir -p "$install_dir"

    tar --extract --gzip --file "$src" --directory "$install_dir" "./${architecture}" ./version
    tar --extract --gzip --file "$optionalSrc" --directory "$install_dir" "./DB/${architecture}" ./DBX

    runHook postInstall
  '';

  passthru = {
    # nix-update-script's custom dependencies require outputHash and reject
    # this fetchurl source; gitUpdater cannot hash the companion tarball.
    # update.sh therefore refreshes both release-asset hashes together.
    updateScript = ./update.sh;
    tests.smoke = runCommand "${pname}-smoke" { } ''
      test -s ${finalAttrs.finalPackage}/share/${pname}/${architecture}/DBXUpdate.bin
      test -s ${finalAttrs.finalPackage}/share/${pname}/DB/${architecture}/DBUpdate2024.bin
      test -s ${finalAttrs.finalPackage}/share/${pname}/DBX/DBXUpdate2024.bin
      touch "$out"
    '';
  };

  meta = {
    description = "Secure Boot objects recommended by Microsoft";
    homepage = "https://github.com/microsoft/secureboot_objects";
    changelog = "https://github.com/microsoft/secureboot_objects/releases/tag/v${version}-signed";
    license = lib.licenses.bsd2Patent;
    sourceProvenance = with lib.sourceTypes; [ binaryFirmware ];
    platforms = builtins.attrNames architectures;
    maintainers = with lib.maintainers; [ codgician ];
  };
})
