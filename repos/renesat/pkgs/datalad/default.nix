{ python38Packages }:

with python38Packages;

buildPythonPackage rec {
  pname = "datalad";
  version = "0.15.1";

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "CpBbPDQZeGroW2GnruNLD8nuzYFPOECPJ2eucSK1eos=";
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
