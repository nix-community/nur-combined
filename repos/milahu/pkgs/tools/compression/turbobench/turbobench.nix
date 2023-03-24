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
    fetchSubmodules = true;
  };

  # fix: Segmentation fault
  # https://github.com/powturbo/TurboBench/issues/34
  postPatch = ''
    sed -i 's/ -O3 / -O1 /g' makefile
  '';

  #  echo "enabling debug build"
  #  sed -i 's/ -O3 / -O1 -g /g' makefile
  #dontStrip = true;

  makeFlags = [
    #"NCODEC0=1" # Minimum codecs
    #"NCODEC1=1" # Popular codecs
    "NCODEC2=1" # Notable codecs
    # TODO bzip2
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
      gpl2Only
      bsd3 # zlib zlib-ng zstd
      gpl1Only # quicklz Turbo-Range-Coder
      # TODO use licensee on /nix/store/2mvbi396994hrf6l3xal4pmjqln83skv-source
    ];
    maintainers = with maintainers; [ ];
  };
}
