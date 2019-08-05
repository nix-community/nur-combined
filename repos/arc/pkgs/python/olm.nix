{ lib, fetchFromGitHub, pythonPackages, olm }: pythonPackages.buildPythonPackage {
  pname = "python-olm";
  version = olm.version;

  inherit (olm) src;
  sourceRoot = "${olm.name}/python";
  buildInputs = [ olm ];

  propagatedBuildInputs = with pythonPackages; [
    cffi
    future
  ] ++ lib.optional pythonPackages.python.isPy2 typing;
}
