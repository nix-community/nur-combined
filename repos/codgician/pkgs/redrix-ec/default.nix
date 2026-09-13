{
  lib,
  gcc13Stdenv,
  gcc-arm-embedded-13,
  fetchFromGitHub,
  fetchgit,
  python3,
  pkg-config,
  openssl,
  ncurses,
  nix-update-script,
}:

gcc13Stdenv.mkDerivation (finalAttrs: {
  pname = "redrix-ec";
  version = "0-unstable-2026-09-09";

  src = fetchFromGitHub {
    owner = "codgician";
    repo = "redrix-ec";
    rev = "2fe5c32ebde1c75353c74491a1c257b18d9edb73";
    hash = "sha256-OIAxxEY6GH8nmmakRtvEK9eE2e0gLN/9ogYleUKiBE4=";
  };

  cryptoc = fetchgit {
    url = "https://chromium.googlesource.com/chromiumos/third_party/cryptoc";
    rev = "0dd679081b9c8bfa2583d74e3a17a413709ea362";
    hash = "sha256-4ZOuFhlQejypLFXnMRZBP1rpimhJ+2hSYZfTNp/BkBo=";
  };

  nativeBuildInputs = [
    gcc-arm-embedded-13
    python3
    pkg-config
  ];
  buildInputs = [
    openssl
    ncurses
  ];
  strictDeps = true;
  hardeningDisable = [ "all" ];
  dontConfigure = true;
  dontStrip = true;
  dontPatchELF = true;
  enableParallelBuilding = true;

  # Upstream's packaging interface generates the firmware version without Git.
  VCSID = finalAttrs.src.rev;
  REPRODUCIBLE_BUILD = "1";
  firmwareIdentity = "redrix_v2.1.9999-${builtins.substring 0 8 finalAttrs.src.rev}";

  postPatch = ''
    patchShebangs util
  '';

  # EC's makefiles use `out` for their build directory, whereas Nix exports it
  # as the output path. Always override it explicitly, including for host tests.
  makeFlags = [
    "BOARD=redrix"
    "out=build/redrix"
    "CROSS_COMPILE=${gcc-arm-embedded-13}/bin/arm-none-eabi-"
    "BUILDCC=cc"
    "HOSTCC=cc"
    "EXTRA_CFLAGS=-Wno-array-bounds -Wno-address -Wno-stringop-truncation"
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    # Host test output directories are selected recursively by make.
    env -u out make -j"$NIX_BUILD_CORES" host-lid_sw host-kb_mkbp \
      BUILDCC=cc HOSTCC=cc CROSS_COMPILE= HOST_CROSS_COMPILE= \
      CROSS_COMPILE_CC_NAME=gcc CRYPTOC_DIR="$cryptoc" \
      EXTRA_CFLAGS='-Wno-array-bounds -Wno-address -Wno-stringop-truncation'
    python3 util/run_host_test.py lid_sw
    python3 util/run_host_test.py kb_mkbp
    test "$(stat -c %s build/redrix/ec.bin)" = 524288
    for section in RO RW; do
      image="build/redrix/$section/ec.$section.flat"
      size=$(stat -c %s "$image")
      test "$size" -gt 0 && test "$size" -le 262144
      grep -aFq "$firmwareIdentity" "$image"
      offset=0
      if [ "$section" = RW ]; then offset=262144; fi
      cmp "$image" <(dd if=build/redrix/ec.bin bs=1 skip="$offset" count="$size" status=none)
    done
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    firmwareDir="$out/share/firmware/redrix-ec"
    mkdir -p "$firmwareDir"
    cp build/redrix/ec.bin "$firmwareDir/"
    cp build/redrix/{RO,RW}/ec.*.{flat,elf} build/redrix/RW/ec.RW.bin "$firmwareDir/"
    cp build/redrix/ec_version.h "$firmwareDir/"
    printf '%s\n' '${finalAttrs.src.rev}' > "$firmwareDir/source-revision"
    (cd "$firmwareDir"; sha256sum *.bin *.flat > SHA256SUMS)
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=my" ]; };

  meta = {
    description = "Redrix embedded-controller firmware with codgician's downstream patches";
    homepage = "https://github.com/codgician/redrix-ec";
    license = lib.licenses.bsd3;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    maintainers = [ lib.maintainers.codgician ];
  };
})
