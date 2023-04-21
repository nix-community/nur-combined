{ python3Packages, ssh-python, ssh2-python }:

python3Packages.buildPythonPackage rec {
  pname = "parallel-ssh";
  version = "2.10.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-i5JfQ5cqVJrgkKVfVXvrU6GWhWZtvrFmswQ9YfXrLbk=";
  };
  propagatedBuildInputs = [
    python3Packages.gevent
    ssh2-python
    ssh-python
  ];
}

