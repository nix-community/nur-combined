{lib, python3Packages, procset}:
python3Packages.buildPythonPackage rec {
  pname = "evalys";
  version = "4.0.7";
  name = "${pname}-${version}";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-PxND5AJ2ymjbWM9ZhAF6FfL1Z1jcoYD+D3iv8gC+hRg=";
  };

  propagatedBuildInputs = with python3Packages; [
    procset
    seaborn
    pandas
    pyqt5
    ipywidgets
    matplotlib
  ];

  # FIXME: tests are not passing and need to be refactored...
  doCheck = false;

  meta = with lib; {
    description = "Infrastructure Performance Evaluation Toolkit Edit";
    homepage    = https://github.com/oar-team/evalys;
    platforms   = python3Packages.debugpy.meta.platforms; # TODO: be more precise if possible
    license = licenses.bsd3;
    longDescription = ''
        Evalys is a data analytics library made to load, compute,
        and plot data from job scheduling and resource management traces.
        It allows scientists and engineers to extract useful data and
        visualize it interactively or in an exported file.
    '';
    broken = false;
  };
}
