{ python3Packages, fetchFromGitLab, execo, ansible, iotlabsshcli, distem, python-grid5000 }:

python3Packages.buildPythonPackage rec {
  pname = "enoslib";
  version = "v8.1.4";
  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "discovery";
    repo = pname;
    rev = "${version}";
    sha256 = "sha256-hGDneTQUexCBmZhnmZyIIeIlM87IzGCrIWWjC7plXk4=";
  };

  # We do the following because nix cannot yet access the extra builds of poetry
  patchPhase = ''
    substituteInPlace setup.cfg --replace "importlib_resources>=5,<6" ""
    substituteInPlace setup.cfg --replace "importlib_metadata>=6,<7" ""
    substituteInPlace setup.cfg --replace "rich[jupyter]~=12.0.0" "rich>=12.0.0"
    substituteInPlace setup.cfg --replace "packaging~=21.3" "packaging>=21.3"
    substituteInPlace setup.cfg --replace "pytz~=2022.1" "pytz>=2022.1"
    substituteInPlace setup.cfg --replace "ansible>=2.9,<7.2" "ansible>=2.9"
  '';
  propagatedBuildInputs = [
    python3Packages.cryptography
    python3Packages.ansible
    python3Packages.sshtunnel
    python3Packages.python-vagrant
    python3Packages.ipywidgets
    python3Packages.rich
    python3Packages.jsonschema
    python3Packages.packaging
    python3Packages.pytz

    ansible

    distem
    iotlabsshcli
    execo
    python-grid5000
  ];
  doCheck = false;
  meta.broken = true;
  # checkInputs = [
  #   python3Packages.pytest
  #   python3Packages.ansible
  #   ansible
  # ];
}
