{ python3Packages, fetchFromGitLab }:

python3Packages.buildPythonPackage rec {
  pname = "distem";
  version = "0.0.5";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "myriads-team";
    repo = "python-distem";
    rev = "650931b377c35470e3c72923f9af2fd9c37f0470";
    sha256 = "sha256-brrs350eC+vBzLJmdqw4FnjNbL+NgAfnqWDjsMiEyZ4=";
  };
  propagatedBuildInputs = [
    python3Packages.requests
  ];
}
