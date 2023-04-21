{ lib, pkgs, fetchFromGitHub, python3Packages, libpowercap }:

python3Packages.buildPythonApplication rec {
  name = "colmet-${version}";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "oar-team";
    repo = "colmet";
    rev = "4cc29227fcaf5236d97dde74b9a52e04250a5b77";
    sha256 = "1g2m6crdmlgk8c57qa1nss20128dnw9x58yg4r5wdc7zliicahqq";
  };

  buildInputs = [ libpowercap ];

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
    platforms   = libpowercap.meta.platforms;
    licence     = licenses.gpl2;
    longDescription = ''
    '';
    broken = true; # due to libpowercap
  };
}
