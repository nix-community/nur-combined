{
  lib,
  gcc14Stdenv,
  fetchFromGitHub,
  coreboot-toolchain,
  pkgsCross,
  redrix-ec,
  python3,
  bison,
  flex,
  pkg-config,
  ncurses,
  openssl,
  zlib,
  libuuid,
  nasm,
  imagemagick,
  which,
  perl,
}:

let
  toolchain = coreboot-toolchain.i386;
  # EDK2's LVGL renderer needs the hosted compiler's standard C headers.
  payloadCC = pkgsCross.gnu64.gcc14Stdenv.cc;
  # Match EDK2_TAG_OR_REV in coreboot's payloads/external/edk2/Kconfig.
  edk2 = fetchFromGitHub {
    owner = "MrChromebox";
    repo = "edk2";
    tag = "26.09";
    fetchSubmodules = true;
    hash = "sha256-PxhUKfKMh+4YkaXiwcleaJV+y/FFcP0ANqyXYSfvAmo=";
  };
in
gcc14Stdenv.mkDerivation (finalAttrs: {
  pname = "redrix-coreboot";
  version = "MrChromebox-2606.1-unstable-2026-09-12";

  src = fetchFromGitHub {
    owner = "codgician";
    repo = "coreboot";
    rev = "e317bd232e1d028cbe89077d7b2ddbfabedcb6af";
    fetchSubmodules = true;
    hash = "sha256-bm4189GFDGK2b2qz6NCjF2g3o6OxovnxcGt/phpAO/w=";
  };

  nativeBuildInputs = [
    toolchain
    payloadCC
    payloadCC.cc
    python3
    bison
    flex
    pkg-config
    nasm
    imagemagick
    which
    perl
  ];
  buildInputs = [
    ncurses
    openssl
    zlib
    libuuid
  ];
  strictDeps = true;
  hardeningDisable = [ "all" ];
  dontStrip = true;
  enableParallelBuilding = true;

  # Resolve through PATH: Nix puts gcc and its gcc-ar helper in separate outputs.
  GCC_BIN = payloadCC.targetPrefix;

  postUnpack = ''
    mkdir -p "$sourceRoot/payloads/external/edk2/workspace/mrchromebox"
    cp -r ${edk2}/. "$sourceRoot/payloads/external/edk2/workspace/mrchromebox/"
    chmod -R u+w "$sourceRoot"
  '';

  # Upstream unconditionally fetches/checks out EDK2 even when it is already
  # present. Nix supplies the complete pinned source before the build instead.
  patches = [ ./edk2-offline.patch ];

  postPatch = ''
    patchShebangs util 3rdparty/vboot payloads/external/edk2
  '';

  makeFlags = [
    "V=1"
    "XGCCPATH=${toolchain}/bin/"
    "UPDATED_SUBMODULES=1"
    "CPUS=$(NIX_BUILD_CORES)"
    "BUILD_TIMELESS=1"
    "KERNELVERSION=nur-${builtins.substring 0 12 finalAttrs.src.rev}"
  ];

  configurePhase = ''
    runHook preConfigure
    cp configs/adl/config.redrix.uefi .config
    cp ${redrix-ec}/share/firmware/redrix-ec/ec.RW.flat redrix-ec.RW.flat
    util/scripts/config \
      --set-str EC_GOOGLE_CHROMEEC_FIRMWARE_FILE redrix-ec.RW.flat
    make "''${makeFlagsArray[@]}" olddefconfig
    # A source update selecting a new payload release requires updating its pin.
    grep -qx 'CONFIG_EDK2_TAG_OR_REV="${edk2.tag}"' .config
    runHook postConfigure
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    test "$(stat -c %s build/coreboot.rom)" = 33554432
    grep -qx CONFIG_BOARD_GOOGLE_REDRIX=y .config
    grep -qx CONFIG_PAYLOAD_EDK2=y .config
    build/cbfstool build/coreboot.rom print > cbfs.txt
    build/cbfstool build/coreboot.rom extract -n ecrw -f ecrw.extracted
    cmp redrix-ec.RW.flat ecrw.extracted
    build/cbfstool build/coreboot.rom extract -n ecrw.hash -f ecrw.hash.extracted
    openssl dgst -sha256 -binary redrix-ec.RW.flat > ecrw.hash.expected
    cmp ecrw.hash.expected ecrw.hash.extracted
    grep -q 'fallback/payload' cbfs.txt
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    firmwareDir="$out/share/firmware/redrix-coreboot"
    mkdir -p "$firmwareDir"
    cp build/coreboot.rom build/UEFIPAYLOAD.fd "$firmwareDir/"
    cp .config "$firmwareDir/coreboot.config"
    cp cbfs.txt "$firmwareDir/"
    printf '%s\n' '${finalAttrs.src.rev}' > "$firmwareDir/source-revision"
    printf '%s\n' '${edk2.tag}' > "$firmwareDir/edk2-version"
    cp ${redrix-ec}/share/firmware/redrix-ec/source-revision "$firmwareDir/ec-source-revision"
    (cd "$firmwareDir"; sha256sum coreboot.rom UEFIPAYLOAD.fd > SHA256SUMS)
    runHook postInstall
  '';

  passthru = {
    inherit redrix-ec edk2;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Redrix coreboot UEFI firmware with codgician's EC firmware";
    homepage = "https://github.com/codgician/coreboot";
    license = with lib.licenses; [
      gpl2Only
      bsd2Patent
      unfreeRedistributableFirmware
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryFirmware
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ lib.maintainers.codgician ];
  };
})
