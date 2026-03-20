{
  lib,
  stdenvNoCC,
  makeWrapper,
  coreutils,
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
}:

stdenvNoCC.mkDerivation rec {
  pname = "kvm-archive";
  version = "0.0.0";

  src = ./kvm-archive;

  buildInputs = [
    coreutils
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
    makeWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    ### Make gsettings-diff available
    mkdir -p $out/bin
    cp ${src} $out/bin/${pname}

    ### Change to executable file
    chmod +x $out/bin/${pname}
  '';

  postFixup = ''
    ### Add runtime path to gsettings-diff wrapper
    wrapProgram $out/bin/${pname} \
      --set PATH ${
        lib.makeBinPath [
          coreutils
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
        ]
      }
  '';

  meta = {
    description = "A tool for import and export libvirt vm";
    mainProgram = "kvm-archive";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
