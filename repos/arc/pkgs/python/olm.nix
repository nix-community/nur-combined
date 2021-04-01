{ lib, fetchFromGitHub, pythonPackages, olm }: pythonPackages.buildPythonPackage {
  pname = "python-olm";
  version = olm.version;

  inherit (olm) src;
  sourceRoot =
    if lib.versionAtLeast olm.version "3.2.2" then "source/python"
    else "${olm.name}/python";
  buildInputs = [ olm ];

  propagatedBuildInputs = with pythonPackages; [
    cffi
    future
  ] ++ lib.optional pythonPackages.python.isPy2 typing;
}
