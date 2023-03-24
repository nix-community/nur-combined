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
