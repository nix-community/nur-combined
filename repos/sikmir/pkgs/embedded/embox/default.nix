{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  pkgsCross,
  bash,
  cpio,
  gcc-arm-embedded,
  python3,
  qemu,
  unzip,
  which,
  arch ? "x86",
}:

assert lib.assertOneOf "arch" arch [
  "aarch64"
  "arm"
  "ppc"
  "riscv64"
  "x86"
];

let
  third-party = lib.mapAttrs (name: spec: fetchurl spec) (
    builtins.fromJSON (builtins.readFile ./third-party.json)
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "embox-${arch}-qemu";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "embox";
    repo = "embox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-S9ziXX0DGrrH3Lame2yfMYSYRcCp8jQ3l+yeqGlSJ0g=";
  };

  patches = [ ./0001-fix-build.patch ];

  postPatch = ''
    substituteInPlace mk/extbld/compiler_start.sh \
      --replace "/usr/bin/env bash" "${lib.getExe bash}"
    substituteInPlace templates/aarch64/qemu/build.conf \
      --replace-fail "aarch64-elf" "aarch64-none-elf"
    substituteInPlace templates/ppc/qemu/build.conf \
      --replace-fail "powerpc-elf" "powerpc-none-eabi"
    substituteInPlace templates/riscv64/qemu/build.conf \
      --replace-fail "riscv64-unknown-elf" "riscv64-none-elf"
  '';

  nativeBuildInputs =
    [
      cpio
      python3
      unzip
      which
      makeWrapper
    ]
    ++ lib.optional (arch != "x86" && arch != "arm") pkgsCross."${arch}-embedded".stdenv.cc
    ++ lib.optional (arch == "arm") gcc-arm-embedded;

  configurePhase = "make confload-${arch}/qemu";

  preBuild = ''
    patchShebangs ./mk
    mkdir -p ./download
    ln -s ${third-party.cjson} ./download/cjson-v1.7.16.tar.gz
    ln -s ${third-party.acpica-unix} ./download/acpica-R06_28_23.tar.gz
    ln -s ${third-party.openlibm} ./download/openlibm-0.8.3.tar.gz
  '';

  installPhase =
    let
      platform_args =
        {
          aarch64 = "-M virt -cpu cortex-a53 -m 1024";
          arm = "-M integratorcp -m 256";
          ppc = "-M virtex-ml507 -m 64";
          riscv64 = "-M virt -m 512";
          x86 = "-enable-kvm -device pci-ohci,id=ohci -m 256";
        }
        .${arch};
      net_args = {
        aarch64 = "model=e1000";
        arm = "model=smc91c111";
        x86 = "model=virtio";
      };
      withNetwork = (lib.hasAttr arch net_args) && stdenv.isLinux;
    in
    ''
      mkdir -p $out/bin

      makeWrapper ${qemu}/bin/qemu-system-${if arch == "x86" then "i386" else arch} $out/bin/embox \
        --add-flags "${platform_args}" \
        --add-flags "-kernel $out/share/embox/images/embox.img" \
        --add-flags "${lib.optionalString withNetwork "-net nic,netdev=n0,${net_args.${arch}},macaddr=AA:BB:CC:DD:EE:02"}" \
        --add-flags "${lib.optionalString withNetwork "-netdev tap,script=$out/share/embox/scripts/start_script,downscript=$out/share/embox/scripts/stop_script,id=n0"}" \
        --add-flags "-nographic"

      install -Dm644 build/base/bin/embox $out/share/embox/images/embox.img
      install -Dm644 conf/*.conf* -t $out/share/embox/conf
    ''
    + lib.optionalString withNetwork ''
      install -Dm755 scripts/qemu/{start,stop}_script -t $out/share/embox/scripts
    '';

  meta = {
    description = "Modular and configurable OS for embedded applications";
    homepage = "http://embox.github.io/";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = lib.platforms.unix;
    skip.ci = true;
    mainProgram = "embox";
  };
})
