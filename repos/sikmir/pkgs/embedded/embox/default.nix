{ lib
, stdenv
, fetchFromGitHub
, fetchurl
, makeWrapper
, pkgsCross
, cpio
, gcc-arm-embedded
, python
, qemu
, unzip
, which
, arch ? "x86"
}:

assert lib.assertOneOf "arch" arch [ "aarch64" "arm" "ppc" "riscv64" "x86" ];

let
  third-party = lib.mapAttrs
    (name: spec: fetchurl spec)
    (builtins.fromJSON (builtins.readFile ./third-party.json));
in
stdenv.mkDerivation rec {
  pname = "embox-${arch}-qemu";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "embox";
    repo = "embox";
    rev = "v${version}";
    hash = "sha256-w0xK5NXrLIq47pHEyM+luFmJKFzz+NUgFN/xs1tjf9I=";
  };

  patches = [ ./0001-fix-build.patch ];

  postPatch = ''
    substituteInPlace templates/aarch64/qemu/build.conf \
      --replace "aarch64-elf" "aarch64-none-elf"
    substituteInPlace templates/ppc/qemu/build.conf \
      --replace "powerpc-elf" "powerpc-none-eabi"
    substituteInPlace templates/riscv64/qemu/build.conf \
      --replace "riscv64-unknown-elf" "riscv64-none-elf"
  '';

  nativeBuildInputs = [
    cpio
    python
    unzip
    which
    makeWrapper
  ] ++ lib.optional (arch != "x86" && arch != "arm") pkgsCross."${arch}-embedded".stdenv.cc
    ++ lib.optional (arch == "arm") gcc-arm-embedded;

  configurePhase = "make confload-${arch}/qemu";

  preBuild = ''
    patchShebangs ./mk
    mkdir -p ./download
    ln -s ${third-party.cjson} ./download/cjson.zip
    ln -s ${third-party.acpica-unix} ./download/acpica-unix-20210331.tar.gz
  '';

  installPhase =
    let
      platform_args = {
        aarch64 = "-M virt -cpu cortex-a53 -m 1024";
        arm = "-M integratorcp -m 256";
        ppc = "-M virtex-ml507 -m 64";
        riscv64 = "-M virt -m 512";
        x86 = "-enable-kvm -device pci-ohci,id=ohci -m 256";
      }.${arch};
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
    '' + lib.optionalString withNetwork ''
      install -Dm755 scripts/qemu/{start,stop}_script -t $out/share/embox/scripts
    '';

  meta = with lib; {
    description = "Modular and configurable OS for embedded applications";
    homepage = "http://embox.github.io/";
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    skip.ci = true;
  };
}
