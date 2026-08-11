{ lib
, stdenv
, fetchFromGitHub
, freetz
, dtc
}:

stdenv.mkDerivation rec {
  pname = "yf-akcarea";
  inherit (freetz) version;

  src = freetz.src + "/make/host-tools/yf-akcarea-host/src";

  buildInputs = [
    dtc
  ];

  makeFlags = [
    "LIBFDT_DIR=${dtc}"
    # fix: fatal error: gnu/stubs-32.h: No such file or directory
    "BITNESS="
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp avm_kernel_config.bin2asm avm_kernel_config.extract $out/bin
  '';

  meta = with lib; {
    description = "utilities to replace/recreate missing parts from AVM's open-source package";
    inherit (freetz.meta) homepage;
    maintainers = with maintainers; [ ];
    platforms = platforms.all;
    license = licenses.gpl2;
  };
}
