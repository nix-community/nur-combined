{ lib, pythonPackages, git }:

with pythonPackages;

buildPythonPackage rec {
  pname = "python-socks";
  version = "1.2.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0vg2llf4zpiifa568yvv9hqpljk4a4wki6a8l8mf71q99idv7dby";
  };

  propagatedBuildInputs = with pythonPackages; [ async-timeout trio curio ];
}
