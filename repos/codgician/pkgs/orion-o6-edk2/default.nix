{
  lib,
  gcc14Stdenv,
  fetchFromGitHub,
  edk2-cix,
  glibc,
  libuuid,
  m4,
  patchelf,
  python3,
  nurTests,
}:

gcc14Stdenv.mkDerivation (finalAttrs: {
  pname = "orion-o6-edk2";
  version = "1.3.1-unstable-2026-10-30";

  # Radxa's packaging repository supplies only the board build glue
  # (src/Makefile); the firmware trees are the pins below.
  src = fetchFromGitHub {
    owner = "radxa-pkg";
    repo = "edk2-cix";
    tag = "1.3.1";
    hash = "sha256-SwxzKugIT2DR7Eq1KjkiKR160eAOK6FTwXN00VsEuys=";
  };

  edk2 = fetchFromGitHub {
    owner = "codgician";
    repo = "edk2";
    rev = "62733cbe7a3b0b73a0e30a9d3b7766836485dd28";
    fetchSubmodules = true;
    hash = "sha256-LxWTu6+u3PaPO3eXfNBfwml5jvLz3bY3lmyqM70A3a0=";
  };

  edk2Platforms = fetchFromGitHub {
    owner = "codgician";
    repo = "edk2-platforms";
    rev = "088e0a1e1c6419c003fa24f3d359e1919ed67b04";
    hash = "sha256-cRI1gCiDxXE6voiiENwSW9OpElnQDNoD12R0dmMClFw=";
  };

  edk2NonOsi = fetchFromGitHub {
    owner = "radxa";
    repo = "edk2-non-osi";
    rev = "f567460e07814038c6ff1aef79cc5c71ba237b83";
    hash = "sha256-N/q5R97fRw98OGrGjNMX1JPncl496sd1GsPrap/3HzA=";
  };

  # Commit time of the edk2-platforms pin. It sets the SMBIOS release date and
  # PrePi's __DATE__/__TIME__, so the same pins always give the same volumes.
  env.SOURCE_DATE_EPOCH = "1793366484";

  sourceRoot = "${finalAttrs.src.name}/src";

  # Keep the store timestamps: stdenv derives SOURCE_DATE_EPOCH from the
  # newest source file after this hook, and fresh copies would date it now.
  postUnpack = ''
    for tree in edk2:${finalAttrs.edk2} \
                edk2-platforms:${finalAttrs.edk2Platforms} \
                edk2-non-osi:${finalAttrs.edk2NonOsi}; do
      rm -rf "$sourceRoot/''${tree%%:*}"
      cp -r --preserve=timestamps "''${tree#*:}" "$sourceRoot/''${tree%%:*}"
    done
    chmod -R u+w "$sourceRoot"
  '';

  nativeBuildInputs = [
    edk2-cix.acpica-tools
    libuuid
    m4
    patchelf
    python3
  ];

  # nixpkgs' hardening flags break EDK2's freestanding firmware build.
  hardeningDisable = [ "all" ];

  postPatch = ''
    # The vendor packaging tools are prebuilt for a conventional FHS system.
    for bin in edk2-non-osi/Platform/CIX/Sky1/PackageTool/AARCH64/*; do
      if [ -f "$bin" ] && [ -x "$bin" ] && patchelf --print-interpreter "$bin" > /dev/null 2>&1; then
        patchelf --set-interpreter "$(cat "$NIX_CC/nix-support/dynamic-linker")" \
          --set-rpath ${lib.makeLibraryPath [ glibc ]} "$bin"
      fi
    done

    # The Makefile reads the date, git and the Debian changelog while building;
    # take those identities from the pins instead.
    substituteInPlace Makefile \
      --replace-fail '$(shell date -Is)' '$(BUILD_DATE)' \
      --replace-fail '$(shell git rev-parse --short HEAD)' '$(COMMIT_HASH)' \
      --replace-fail '$(shell cd edk2 && git rev-parse --short HEAD)' '$(EDK2_COMMIT_HASH)' \
      --replace-fail '$(shell cd edk2-non-osi && git rev-parse --short HEAD)' '$(EDK2_NON_OSI_COMMIT_HASH)' \
      --replace-fail '$(shell cd edk2-platforms && git rev-parse --short HEAD)' '$(EDK2_PLATFORMS_COMMIT_HASH)' \
      --replace-fail '$(shell cd .. && dpkg-parsechangelog -S Version)' '$(DEB_VERSION)'

    patchShebangs .
  '';

  makeFlags = [
    "DSC=edk2-platforms/Platform/Radxa/Orion/O6/O6.dsc"
    "COMMIT_HASH=${finalAttrs.src.tag}"
    "EDK2_COMMIT_HASH=${builtins.substring 0 10 finalAttrs.edk2.rev}"
    "EDK2_NON_OSI_COMMIT_HASH=${builtins.substring 0 7 finalAttrs.edk2NonOsi.rev}"
    "EDK2_PLATFORMS_COMMIT_HASH=${builtins.substring 0 8 finalAttrs.edk2Platforms.rev}"
    "DEB_VERSION=${finalAttrs.src.tag}"
    "Build/O6/RELEASE_GCC5/cix_flash_ota.bin"
    "Build/O6/RELEASE_GCC5/cix_flash_all.bin"
  ];

  # EDK2 draws a random stack-cookie table per build and picks each module's
  # entry by Python's per-process string hash. The cookies are readable from
  # any copy of the image anyway, so derive the table from the pins and fix
  # the hash seed: the same pins then always produce the same volumes.
  env.PYTHONHASHSEED = "0";
  preBuild = ''
    mkdir -p Build/O6/RELEASE_GCC5
    python3 - Build/O6/RELEASE_GCC5 ${finalAttrs.edk2.rev} ${finalAttrs.edk2Platforms.rev} <<'EOF'
    import hashlib, json, sys
    out, *pins = sys.argv[1:]
    for bits in (32, 64):
        values = [
            int.from_bytes(hashlib.sha256(f"{bits}:{i}:{':'.join(pins)}".encode()).digest()[: bits // 8], "little")
            % ((1 << bits) - 1)
            for i in range(100)
        ]
        with open(f"{out}/StackCookieValues{bits}.json", "w") as table:
            json.dump(values, table)
    EOF
    makeFlagsArray+=("BUILD_DATE=$(date -u -d "@$SOURCE_DATE_EPOCH" -Iseconds)")
  '';

  # EDK2's own build already runs one job per core.
  enableParallelBuilding = false;

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    out_dir=Build/O6/RELEASE_GCC5
    test "$(stat -c %s "$out_dir/cix_flash_all.bin")" = 8388608
    # The FD is exactly the compact volume, and the packaged images carry it
    # unchanged; the PCR0 prediction below therefore describes them.
    test "$(stat -c %s "$out_dir/FV/FVMAIN_COMPACT.Fv")" = $((0x1f0000))
    python3 - "$out_dir" <<'EOF'
    import sys
    out = sys.argv[1]
    fd = open(f"{out}/FV/FVMAIN_COMPACT.Fv", "rb").read()
    for image in ("cix_flash_ota.bin", "cix_flash_all.bin"):
        assert fd in open(f"{out}/{image}", "rb").read(), image
    EOF
    grep -q FirmwareMeasureDxe "$out_dir/FV/FVMAIN.inf"
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    out_dir=Build/O6/RELEASE_GCC5
    firmwareDir="$out/share/firmware/orion-o6-edk2"
    mkdir -p "$firmwareDir"
    cp "$out_dir"/cix_flash_ota.bin "$out_dir"/cix_flash_all.bin "$out_dir"/BuildOptions "$firmwareDir/"
    cp "$out_dir/FV/FVMAIN_COMPACT.Fv" "$firmwareDir/SKY1_BL33_UEFI.fd"
    cp "$out_dir/FV/FVMAIN.Fv" "$firmwareDir/"

    # FirmwareMeasureDxe extends PCR0 with the extracted FVMAIN before the
    # ReadyToBoot separator, so a healthy boot of this image yields these.
    python3 - "$firmwareDir" <<'EOF'
    import hashlib, sys
    out = sys.argv[1]
    fv = open(f"{out}/FVMAIN.Fv", "rb").read()
    with open(f"{out}/pcr0", "w") as pcr0:
        for alg in ("sha256", "sha384"):
            value = bytes(hashlib.new(alg).digest_size)
            for digest in (hashlib.new(alg, fv).digest(), hashlib.new(alg, bytes(4)).digest()):
                value = hashlib.new(alg, value + digest).digest()
            pcr0.write(f"{alg}:{value.hex()}\n")
    EOF

    printf '%s\n' '${finalAttrs.edk2.rev}' > "$firmwareDir/edk2-source-revision"
    printf '%s\n' '${finalAttrs.edk2Platforms.rev}' > "$firmwareDir/edk2-platforms-source-revision"
    printf '%s\n' '${finalAttrs.edk2NonOsi.rev}' > "$firmwareDir/edk2-non-osi-source-revision"
    (cd "$firmwareDir"; sha256sum cix_flash_ota.bin cix_flash_all.bin SKY1_BL33_UEFI.fd FVMAIN.Fv > SHA256SUMS)
    runHook postInstall
  '';

  passthru = {
    tests = {
      inherit (nurTests) orion-o6-edk2;
    };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Radxa Orion O6 UEFI firmware with firmware TPM and measured boot";
    homepage = "https://github.com/codgician/edk2-platforms";
    license = with lib.licenses; [
      bsd2Patent
      unfreeRedistributableFirmware
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryFirmware
    ];
    # The board's packaging tools are run natively; only aarch64 is verified.
    platforms = [ "aarch64-linux" ];
    maintainers = [ lib.maintainers.codgician ];
  };
})
