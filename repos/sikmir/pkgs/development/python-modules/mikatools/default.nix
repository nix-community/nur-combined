{ lib, python3Packages, sources }:

python3Packages.buildPythonPackage {
  pname = "mikatools-unstable";
  version = lib.substring 0 10 sources.mikatools.date;

  src = sources.mikatools;

  propagatedBuildInputs = with python3Packages; [ requests clint ];

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    inherit (sources.mikatools) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
