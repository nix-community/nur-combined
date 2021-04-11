{ lib
, fetchurl
, buildPythonApplication
, pbr
, requests
}:

buildPythonApplication rec {
  pname = "git-review";
  version = "2.0.0";

  # Manually set version because prb wants to get it from the git
  # upstream repository (and we are installing from tarball instead)
  PBR_VERSION = version;

  src = fetchurl {
    url = "https://opendev.org/opendev/${pname}/archive/${version}.tar.gz";
    hash = "sha256-0koFKlYDd+KAylZyA5iJcMRZcWps6EhCUHrXLl5pfjY=";
  };

  propagatedBuildInputs = [ pbr requests ];

  # Don't do tests because they require gerrit which is not packaged
  doCheck = false;

  meta = with lib; {
    description = "Tool to submit code to Gerrit";
    homepage = "https://opendev.org/opendev/git-review";
    license = licenses.asl20;
    maintainers = with maintainers; [ metadark ];
  };
}
