{ stdenv, nanomsg, gmp, libpcap, boost, protobuf3_2, thrift-0_10, judy, grpc
, openssl, pi, pkg-config, automake, autoconf, libtool, python2, fetchFromGitHub }:
let 
  src = fetchFromGitHub { 
    owner = "p4lang";
    repo = "behavioral-model";
    rev = "b447ac4c0cfd83e5e72a3cc6120251c1e91128ab";
    sha256 = "sha256-ugDIH/gEaFCRnzCjybEh09+rtlIY8vjI6cV3b8p8dsc=";
    fetchSubmodules = true; 
  };

  bmv2 = stdenv.mkDerivation {
    name = "bmv2";
    inherit src;
    buildInputs =
      [ nanomsg gmp libpcap boost protobuf3_2 thrift-0_10 judy grpc openssl pi ];
    nativeBuildInputs = [ python2 pkg-config automake autoconf libtool ];
    postPatch = ''
      patchShebangs tools/get_version.sh
      substituteInPlace src/bm_runtime/Makefile.am \
        --replace 'noinst_LTLIBRARIES' 'lib_LTLIBRARIES'
      substituteInPlace targets/simple_switch/Makefile.am \
        --replace 'lib_LTLIBRARIES = libsimpleswitch_runner.la' 'lib_LTLIBRARIES += libsimpleswitch_runner.la' \
        --replace 'noinst_LTLIBRARIES' 'lib_LTLIBRARIES'
    '';
    preConfigure = ''
      ./autogen.sh
    '';
    enableParallelBuilding = true;
    configureFlags = [ "--enable-debugger" "--with-pi" ];
  };

  simple_switch_grpc = stdenv.mkDerivation {
    name = "simple_switch_grpc";
    inherit src;
    sourceRoot = "source/targets/simple_switch_grpc";
    postPatch = ''
      substituteInPlace Makefile.am \
        --replace '$(builddir)/../simple_switch/libsimpleswitch.la' '${bmv2}/lib/libsimpleswitch.la' \
        --replace '$(builddir)/../../PI/libbmpi.la' '${bmv2}/lib/libbmpi.la' \
        --replace '$(builddir)/../../src/bm_runtime/libbmruntime.la' '${bmv2}/lib/libbmruntime.la' \
        --replace '$(builddir)/../../thrift_src/libruntimestubs.la' '${bmv2}/lib/libruntimestubs.la' \
        --replace '$(builddir)/../simple_switch/libsimpleswitch_thrift.la' '${bmv2}/lib/libsimpleswitch_thrift.la' \
        --replace '-lpifeproto' '-lpip4info -lpifeproto' \
        --replace tests ""
    '';
    preConfigure = ''
      ./autogen.sh
    '';
    buildInputs = [ grpc openssl boost bmv2 pi gmp judy thrift-0_10 ];
    nativeBuildInputs = [ pkg-config autoconf automake libtool protobuf3_2 ];
    enableParallelBuilding = false;
    configureFlags = [ "--with-thrift" ];
  };
in bmv2.overrideAttrs (_: { passthru = { targets = { inherit simple_switch_grpc; }; }; })
