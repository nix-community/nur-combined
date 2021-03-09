{ stdenv
, lib
, fetchurl
, python3Packages
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
    python3Packages.python-constraint
  ];

  postPatch = ''
    for exe in bin/*; do
      substituteInPlace $exe --replace 'MYPATH=`realpath $0`' 'MYPATH=`realpath -s $0`'
    done
  '';

  installPhase = ''
    mkdir -p $out
    cp -r bin share $out/

    buildPythonPath "$out $propagatedBuildInputs"
    patchPythonScript $out/share/symbiflow/scripts/prjxray_create_place_constraints.py
  '';
}
