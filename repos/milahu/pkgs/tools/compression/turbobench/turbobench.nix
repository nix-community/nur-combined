{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "turbobench";
  version = "2023-03";

  src = fetchFromGitHub {
    owner = "powturbo";
    repo = "TurboBench";
    rev = version;
    hash = "sha256-k/KMGuCZB74rnhx/lno49SY5omqiSBa0T04CwjSwEkU=";
    /*
    # also segfault
    rev = "51e296184bdb450ad3a99f678c22b2c515c37f5f";
    hash = "sha256-ZPlykx1sJYvBplFtbyywavNDwGRgVBTD+HJyRuH7kbw=";
    */
    fetchSubmodules = true;
  };

  # TODO debug: Segmentation fault
  # https://github.com/powturbo/TurboBench/issues/34
  #debugBuild = true;
  # fixme: CFLAGS/CXXFLAGS are not used
  #NIX_CFLAGS_COMPILE = "-Os -g -Wall";
  postPatch = ''
    echo "enabling debug build"
    sed -i 's/ -O3 /&-g /g' makefile
  '';
  dontStrip = true;

  makeFlags = [
    #"NCODEC0=1" # Minimum codecs
    #"NCODEC1=1" # Popular codecs
    "NCODEC2=1" # Notable codecs
    "EC=1" # Entropy Coder codecs
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp turbobench $out/bin
  '';

  meta = with lib; {
    description = "Compression Benchmark";
    homepage = "https://github.com/powturbo/TurboBench";
    license = with licenses; [
      bsd3 # zlib zlib-ng zstd
      gpl1Only # quicklz Turbo-Range-Coder
      # TODO use licensee on /nix/store/2mvbi396994hrf6l3xal4pmjqln83skv-source
    ];
    maintainers = with maintainers; [ ];
  };
}
