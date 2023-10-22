{ stdenv
, lib
, fetchFromGitHub
, libusb1
, abseil-cpp
, flatbuffers
, xxd
}:

let
  flatbuffers_1_12 = flatbuffers.overrideAttrs (oldAttrs: rec {
    version = "1.12.0";
    NIX_CFLAGS_COMPILE = "-Wno-error=class-memaccess -Wno-error=maybe-uninitialized";
    cmakeFlags = (oldAttrs.cmakeFlags or []) ++ ["-DFLATBUFFERS_BUILD_SHAREDLIB=ON"];
    NIX_CXXSTDLIB_COMPILE = "-std=c++17";
    configureFlags = (oldAttrs.configureFlags or []) ++ ["--enable-shared"];
    src = fetchFromGitHub {
      owner = "google";
      repo = "flatbuffers";
      rev = "v${version}";
      sha256 = "sha256-L1B5Y/c897Jg9fGwT2J3+vaXsZ+lfXnskp8Gto1p/Tg=";
    };
  });

in stdenv.mkDerivation rec {
  pname = "libedgetpu";
  version = "grouper";

  src = fetchFromGitHub {
    owner = "google-coral";
    repo = pname;
    rev = "release-${version}";
    sha256 = "sha256-73hwItimf88Iqnb40lk4ul/PzmCNIfdt6Afi+xjNiBE=";
  };

  patches = [ ./libedgetpu-stddef.diff ];

  makeFlags = ["-f" "makefile_build/Makefile" "libedgetpu" ];

  buildInputs = [
    libusb1
    abseil-cpp
    flatbuffers_1_12
  ];

  nativeBuildInputs = [
    xxd
  ];

  NIX_CXXSTDLIB_COMPILE = "-std=c++17";

  TFROOT = "${fetchFromGitHub {
    owner = "tensorflow";
    repo = "tensorflow";
    rev = "v2.7.4";
    sha256 = "sha256-liDbUAdaVllB0b74aBeqNxkYNu/zPy7k3CevzRF5dk0=";
  }}";

  enableParallelBuilding = false;

  installPhase = ''
    mkdir -p $out/lib
    cp out/direct/k8/libedgetpu.so.1.0 $out/lib
    ln -s $out/lib/libedgetpu.so.1.0 $out/lib/libedgetpu.so.1
    mkdir -p $out/lib/udev/rules.d
    cp debian/edgetpu-accelerator.rules $out/lib/udev/rules.d/99-edgetpu-accelerator.rules
  '';
}
