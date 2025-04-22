{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  perlPackages,
  rsync,
  rdma-core,
  iproute2,
  gawk,
  gnused,
  procps,
  gnugrep,
  nettools,
  which,
  coreutils-full,
  ethtool,
  wirelesstools,
  getent,
}:

let
  perlDeps = [
    perlPackages.StatisticsDescriptive
    /*
    perlPackages.DateTime
    perlPackages.DateTimeFormatW3CDTF
    perlPackages.DevelCover
    perlPackages.GD
    perlPackages.JSONXS
    perlPackages.PathTools
    */
  ];
in

stdenv.mkDerivation rec {
  pname = "parsyncfp2";
  version = "unstable-2024-05-07";

  src = fetchFromGitHub {
    owner = "hjmangalam";
    repo = "parsyncfp2";
    rev = "8bcd266ca070dfc88be941683531b1fef9a493cf";
    hash = "sha256-MsfncyAXjcIFx/4u0OSFIq34fSKZeXiU91t1EgbbPbs=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildInputs = [
    rsync
    iproute2 # ip
    gawk # awk
    gnused # sed
    procps # ps sysctl
    gnugrep # grep
    nettools # netstat hostname ifconfig route
    which
    coreutils-full # cat ls wc date tr du sort cut uname head pwd md5sum basename dirname split sync
    ethtool
    getent

    # optional
    wirelesstools # iwconfig
    rdma-core # perfquery ibstat
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp parsyncfp2 scut stats $out/bin
    mkdir -p $out/share/doc/parsyncfp2
    cp parsyncfp2-manual.html parsyncfp2-manual.adoc $out/share/doc/parsyncfp2

    runHook postInstall
  '';

  # note: we also add $out/bin to PATH for scut
  postInstall = ''
    wrapProgram $out/bin/parsyncfp2 \
      --prefix PATH : ${lib.makeBinPath buildInputs}:$out/bin

    wrapProgram $out/bin/scut \
      --set PERL5LIB ${perlPackages.makeFullPerlPath perlDeps}
  '';

  meta = {
    description = "MultiHost parallel rsync wrapper";
    homepage = "https://github.com/hjmangalam/parsyncfp2";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "parsyncfp2";
    platforms = lib.platforms.all;
  };
}
