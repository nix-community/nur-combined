{ buildPythonApplication, fetchFromGitLab, lib
, numpy, h5py, pyqt5, qtpy, future, vtk
} :

buildPythonApplication rec {
  pname = "Pegamoid";
  version = "2.6.1";

  src = fetchFromGitLab {
    owner = "jellby";
    repo = pname;
    rev = "v${version}";
    sha256 = "10kv8gsn69p3lgg8s9ayl3v2088zladf3pabd1pqnm81cizgf5yj";
  };

  patches = [
    ./pipVTK.patch
  ];

  propagatedBuildInputs = [
    numpy
    h5py
    pyqt5
    qtpy
    vtk
    future
  ];

  meta = with lib; {
    description = "Python GUI for OpenMolcas";
    homepage = "https://pypi.org/project/Pegamoid";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ maintainers.sheepforce ];
  };
}
