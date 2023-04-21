{ python3Packages, fetchFromGitHub, wirerope }:

python3Packages.buildPythonPackage rec {
  name = "ring";
  version = "0.9.1";
  src = fetchFromGitHub {
    owner = "youknowone";
    repo = name;
    rev = "8e4eb90b13d6480e50c63266e041e491c7c41dfe";
    sha256 = "sha256-VmNXfntVFlXmvx9OjZ0VuIlHY5CPS3N+MJlL8YkrKcw=";
  };
  propagatedBuildInputs = with python3Packages; [
    attrs
    wirerope
  ];
  doCheck = false;
}
