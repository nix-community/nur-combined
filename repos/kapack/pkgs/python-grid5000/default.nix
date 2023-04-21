{ python3Packages, fetchFromGitLab }:

python3Packages.buildPythonPackage rec {
  pname = "python-grid5000";
  version = "1.2.4";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "msimonin";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-wfDyoaOn0Dlbz/metxskbN4frsJbkEe8byUeO01upV8=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    python3Packages.pyyaml
    python3Packages.requests
    python3Packages.ipython
  ];
}
