{
  lib,
  stdenvNoCC,
  makeWrapper,
  coreutils,
  getent,
  gawk,
  gnused,
  findutils,
  gnugrep,
  pv,
  libvirt,
  qemu_kvm,
  gnutar,
  gzip,
  xz,
  zstd,
  zfs,
}:

stdenvNoCC.mkDerivation rec {
  pname = "kvm-archive";
  version = "0.0.0";

  src = ./.;

  dontUnpack = true;

  buildInputs = [
    coreutils
    getent
    gnused
    findutils
    gnugrep
    gawk
    pv
    libvirt
    qemu_kvm
    gnutar
    gzip
    xz
    zstd
    zfs
  ];

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/lib/kvm-archive
    cp $src/src/kvm-archive $out/bin/${pname}
    chmod +x $out/bin/${pname}
    cp $src/src/lib/*.sh $out/lib/kvm-archive/
  '';

  postFixup = ''
    wrapProgram $out/bin/${pname} \
      --set KVM_ARCHIVE_LIB_DIR $out/lib/kvm-archive \
      --set PATH ${
        lib.makeBinPath [
          coreutils
          getent
          gnused
          findutils
          gnugrep
          gawk
          pv
          libvirt
          qemu_kvm
          gnutar
          gzip
          xz
          zstd
          zfs
        ]
      }
  '';

  meta = {
    description = "A tool for import and export libvirt vm";
    mainProgram = "kvm-archive";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
