{ buildPythonPackage, fetchFromGitHub,
  olm, cffi, future, typing }:

buildPythonPackage {
  pname = "python-olm";
  version = "dev";

  inherit (olm) src;
  sourceRoot = "${olm.name}/python";
  buildInputs = [ olm ];

  preBuild = ''
    make include/olm/olm.h
  '';

  propagatedBuildInputs = [
    cffi
    future
    typing
  ];

  doCheck = false;
}
