{ lib
, stdenv
, fetchurl
, pkgs
, maintainers
, flux-core
, llvmPackages_14
}:


llvmPackages_14.stdenv.mkDerivation rec {
  pname = "flux-sched";
  version = "0.25.0";

  src = fetchurl {
    url = "https://github.com/flux-framework/flux-sched/releases/download/v${version}/flux-sched-${version}.tar.gz";
    sha256 = "a984b238d8b6968ef51f1948a550bf57887bf3da8002dcd1734ce26afc4bff07";
  };

  nativeBuildInputs = [
    pkgs.bash
    pkgs.pkgconfig
  ];

  buildInputs = [
    pkgs.valgrind
    pkgs.cudatoolkit
    pkgs.boost179
    pkgs.python310Packages.pyyaml
    pkgs.python310Packages.jsonschema
    pkgs.hwloc
    pkgs.libedit
    pkgs.libxml2
    pkgs.libyamlcpp
    pkgs.jansson
    pkgs.czmq
    pkgs.libuuid
    pkgs.python310
    flux-core
  ];

  # This will error without finding Boost::System if you use pkgs.boost alone
  configureFlags = [
     "--with-boost-libdir=${lib.getLib pkgs.boost179}/lib/"
  ];

  meta = with lib; {
    description = "A next-generation resource manager.";
    homepage = "https://github.com/flux-framework/flux-sched";
    license = licenses.lgpl3;
    maintainers = [ maintainers.vsoch ];
  };
}
