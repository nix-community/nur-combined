{ python38Packages }:

with python38Packages;

buildPythonPackage rec {
  pname = "datalad";
  version = "0.15.3";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-RPjFs5YMbZhIruzYaMgjMMSWiaIel1WX31sRLcLlyfA=";
  };

  propagatedBuildInputs = [
    keyrings-alt
    keyring
    msgpack
    requests
    PyGithub
    annexremote
    boto
    appdirs
    humanize
    patool
    whoosh
    distro
    python-gitlab
    tqdm
    fasteners
    simplejson
    iso8601
  ];
}
