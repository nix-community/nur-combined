{ stdenv
, lib
, fetchurl
, prjxray-db
, python3Packages
, vtr
, yosys
, yosys-symbiflow-plugins
, buildNum
, buildDate
, commit
, sha256
}:

stdenv.mkDerivation rec {
  pname   = "symbiflow-arch-defs-bin";
  version = "${buildDate}-g${commit}";

  src = fetchurl {
    inherit sha256;
    url = "https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/${buildNum}/${buildDate}/symbiflow-arch-defs-install-${commit}.tar.xz";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    python3Packages.wrapPython
  ];

  propagatedBuildInputs = [
    python3Packages.lxml
    python3Packages.python-constraint
    python3Packages.python-prjxray
    python3Packages.simplejson
  ];

  postPatch = ''
    for exe in bin/*; do
      substituteInPlace $exe --replace 'MYPATH=`realpath $0`' 'MYPATH=`realpath -s $0`'
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -r bin share $out/

    for exe in $out/bin/symbiflow_*; do
      sed -i '/^set -e/a export PATH=${lib.makeBinPath [ prjxray-db vtr python3Packages.xc-fasm yosys ]}:$PATH' $exe
      sed -i '/^set -e/a export NIX_YOSYS_PLUGIN_DIRS=${lib.makeSearchPath "share/yosys/plugins" [ yosys-symbiflow-plugins ]}' $exe
    done

    buildPythonPath "$out $propagatedBuildInputs"
    for script in $out/share/symbiflow/scripts/*.py; do
      patchPythonScript $script
    done
  '';
}
