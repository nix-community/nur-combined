{ python3Packages
, fetchFromGitHub
, beets
, lib
}:

with python3Packages;
buildPythonPackage rec {
  pname = "beets-originquery";
  version = "unstable-2022-03-11";

  src = fetchFromGitHub {
    owner = "x1ppy";
    repo = "beets-originquery";
    rev = "c353e2b68804cb4dabca0f0f177cee1137888ca4";
    hash = "sha256-vNROKZgCoWtoou9B8hpJwl4Yf6TzQU0TbKJUd94v7vk=";
  };

  nativeBuildInputs = [
    beets
    setuptools-scm
  ];

  propagatedBuildInputs = [ jsonpath_rw ];

  # There's no test
  doCheck = false;

  pythonImportsCheck = [ "beetsplug.originquery" ];

  meta = {
    description = "Plugin for beets that improves album matching";
    homepage = "https://github.com/x1ppy/beets-originquery";
  };
}
