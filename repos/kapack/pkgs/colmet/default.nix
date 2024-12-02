{ lib, pkgs, fetchFromGitHub, python3Packages, powercap }:

python3Packages.buildPythonApplication rec {
  name = "colmet-${version}";
  version = "0.6.10.dev0";

  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "colmet";
    rev = "5046baf9acdaae8522948c2f6bb37f8ea8f8ed5b";
    sha256 = "sha256-9d0QTcCn8bj4L0n0YRZYnLxrzUjtNA9o9nkJ5w3LC2U=";
  };

  buildInputs = [ powercap ];

  propagatedBuildInputs = with python3Packages; [
    pyinotify
    pyzmq
    tables
    requests
  ];

  preBuild = ''
    mkdir -p $out/lib
    sed -i "s#/usr/lib/#$out/lib/#g" colmet/node/backends/perfhwstats.py
    sed -i "s#/usr/lib/#$out/lib/#g" colmet/node/backends/RAPLstats.py
    sed -i "s#/usr/lib/#$out/lib/#g" colmet/node/backends/lib_perf_hw/makefile
    sed -i "s#/usr/lib/#$out/lib/#g" colmet/node/backends/lib_rapl/makefile
  '';

  # Tests do not pass
  doCheck = false;

  meta = with lib; {
    description = "Collecting metrics about process running in cpuset and in a distributed environnement";
    homepage    = https://github.com/oar-team/colmet;
    platforms   = powercap.meta.platforms;
    licence     = licenses.gpl2;
    longDescription = ''
    '';
  };
}
