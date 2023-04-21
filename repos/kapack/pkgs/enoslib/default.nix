{ python3Packages, fetchFromGitLab, execo, ansible, ring, iotlabsshcli, distem, python-grid5000 }:

python3Packages.buildPythonPackage rec {
  pname = "enoslib";
  version = "v8.1.3";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "discovery";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-QopX4YyYef9YkWmlm1wLg7DcXWUCpG+bdE3LxN7udtk=";
  };
  # We do the following because nix cannot yet access the extra builds of poetry
  patchPhase = ''
    substituteInPlace setup.cfg --replace "rich[jupyter]~=12.0.0" "rich>=12.0.0"
  '';
  propagatedBuildInputs = [
    python3Packages.cryptography
    python3Packages.ansible
    python3Packages.sshtunnel
    python3Packages.python-vagrant
    python3Packages.ipywidgets
    python3Packages.rich
    python3Packages.jsonschema

    ansible

    distem
    iotlabsshcli
    ring
    execo
    python-grid5000
  ];
  doCheck = false;
  # checkInputs = [
  #   python3Packages.pytest
  #   python3Packages.ansible
  #   ansible
  # ];
}
