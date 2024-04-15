# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.
{
  buildPythonPackage,
  fetchPypi,
  lib,
  matplotlib,
  numpy,
  pandas,
  pydot,
  pyyaml,
  fetchFromGitHub,
  nix-update-script,
}:
buildPythonPackage rec {
  pname = "hatchet";
  version = "1.3.1a0";

  src = fetchFromGitHub {
    owner = "hatchet";
    repo = "hatchet";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-mNXPv/SFzA2MBkb/EPovhOP3vRdfaEp2RiKFvnEPS7E=";
  };

  propagatedBuildInputs = [pydot pyyaml matplotlib numpy pandas];

  passthru = {
    updateScript = nix-update-script {
      attrPath = pname;
    };
  };

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "A Python library for analyzing hierarchical performance data";
    homepage = "https://github.com/hatchet/hatchet";
  };
}
