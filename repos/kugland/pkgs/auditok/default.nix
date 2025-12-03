{ pkgs
, lib
, python3Packages
, buildPythonPackage ? python3Packages.buildPythonPackage
, fetchPypi ? python3Packages.fetchPypi
,
}:
buildPythonPackage rec {
  pname = "auditok";
  version = "0.1.5";
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-HNsw9VLP7XEgs8E2X6p7ygDM47AwWxMYjptipknFig4=";
  };
  pyproject = true;
  build-system = [ python3Packages.setuptools ];
  propagatedBuildInputs = with python3Packages; [
    pydub
    pyaudio
    tqdm
    matplotlib
    numpy
  ];
  meta = with lib; {
    description = "An audio/acoustic activity detection and audio segmentation tool";
    homepage = "https://github.com/amsehili/auditok";
    license = licenses.mit;
    maintainers = [ lib.maintainers.kugland ];
  };
}
