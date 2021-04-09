{ lib, fetchFromGitHub, pythonPackages, olm }: with pythonPackages; buildPythonPackage {
  pname = "python-olm";
  version = olm.version;

  inherit (olm) src;
  sourceRoot =
    if lib.versionAtLeast olm.version "3.2.2" then "source/python"
    else "${olm.name}/python";
  buildInputs = [ olm ];

  propagatedBuildInputs = [
    cffi
    future
  ] ++ lib.optional python.isPy2 typing;
}
