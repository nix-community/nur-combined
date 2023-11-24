{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "turbobench";
  version = "2023.08.14";

  src = fetchFromGitHub {
    owner = "powturbo";
    repo = "TurboBench";
    # note: git tags can be delted, so use commit hashes
    rev = "d68171773d7576c4323bb7966d01b7d4d2491b65";
    hash = "sha256-aINyF14li8p0FLbBmL2l2zftEORwYBt2wUx2YSJPZKs=";
    # TODO better. generate a sources.nix file for all git modules
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
    # FIXME "turbobench -l2" shows no codecs
    # workaround: add codecs by name, see below
    #"NCODEC0=1" # Minimum codecs
    #"NCODEC1=1" # Popular codecs
    #"NCODEC2=1" # Notable codecs
    #"EC=1" # Entropy Coder codecs

    #"LZTURBO=1" # lzturbo is closed source https://sites.google.com/site/powturbo
    #"STATIC=1"
    #"NMEMSIZE=1" # disable peak memory calculation (for -O3 on linux)
    #"OPENMP=1"

    # NCODEC0: Minimum codecs
    "LZ4=1"
    "ZSTD=1"
    #"ZSTDLIB=1"

    # NCODEC1: Popular codecs
    "BROTLI=1"
    "LZMA=1"
    "ZLIB=1"

    # NCODEC2: Notable codecs
    #"BLOSC=1"
    #"BRIEFLZ=1"
    "BZIP2=1"
    "BZIP3=1"
    #"CSC=1"
    #"DENSITY=1"
    "FASTLZ=1"
    "FLZMA2=1"
    "LIBDEFLATE=1"
    #"GIPFELI=1"
    # glza not working on all systems
    #"GLZA=1"
    #"HEATSHRINK=1"
    #"IGZIP=1"
    "LIBBSC=1"
    #"LIBZLING=1"
    # lizard disabled (conflict between lizard & ZSTD FSE/HUF ) 2023.02.09
    #"LIZARD=1"
    #"LZ4ULTRA=1"
    "LZFSE=1"
    "LZHAM=1"
    "LZLIB=1"
    "LZO=1"
    "LZSA=1"
    "LZSSE=1"
    #"MINIZ=1"
    #"MSCOMPRESS=1"
    #"PYSAP=1"
    # oodle dll 'oo2core_9_win64.dll', 'liboo2corelinuxarm64.so.9' or 'liboo2corelinux64.so.9' must be in the same directory as turbobench[.exe]
    "OODLE=1"
    "QUICKLZ=1"
    #"SHOCO=1"
    #"SLZ=1"
    #"SMALLZ4=1"
    #"SMAZ=1"
    "SNAPPY=1"
    #"SNAPPY_C=1"
    "TURBORC=1"
    "TURBORLE=1"
    #"MRLE=1"
    #"RLE8=1"
    #"ZLIB_NG=1"
    #"UNISHOX2=1"
    #"UNISHOX3=1"
    "ZOPFLI=1"
    "ZPAQ=1"

    # EC: Encoding Entropy coders / RLE
    #"AOM=1"
    "FASTAC=1"
    "FASTHF=1"
    "FASTARI=1"
    "FPAQ0P=1"
    "FPAQC=1"
    #"FREQTAB=1"
    "FPC=1"
    "FQZ0=1"
    # fse,fsehuf disabled as not available in zstd (20230209)
    #"FSE=1"
    #"FSEHUF=1"
    "RANS_S=1"
    #"RECIPARITH=1"
    "SUBOTIN=1"
    #"TORNADO=1"
    "VECRC=1"
    # TurboRC + libsais
    #"TURBORC=1"
    "LIBSAIS=1"

    # TR: Transform
    #"BRC=1"

    # Archived codecs and other codecs (manual download)
    #"CHAMELEON=1"
    #"DAALA=1"
    #"DOBOZ=1"
    #"LZMAT=1"
    #"NAKAMICHI=1"
    #"PITHY=1"
    #"POLAR"
    #"PPMDEC"
    #"LZOMA=1"
    #"SHRINKER=1"
    #"TORNADO=1"
    #"WFLZ=1"
    #"XPACK=1"
    #"YALZ77"
    #"XPACK=1"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp turbobench $out/bin
    cp ${./turbobench_all.sh} $out/bin/turbobench_all
    chmod +xw $out/bin/turbobench_all
    patchShebangs $out/bin
    substituteInPlace $out/bin/turbobench_all \
      --replace 'turbobench=$(which turbobench)' "turbobench=$out/bin/turbobench"
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
