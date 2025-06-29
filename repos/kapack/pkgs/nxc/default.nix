{ lib, python3Packages, fetchFromGitLab, poetry, execo, taktuk }:

python3Packages.buildPythonPackage rec {
  pname = "nxc";
  version = "24.11";
  format = "pyproject";

  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "nixos-compose";
    repo = "nixos-compose";
    rev = "c748d9dae0499edca792ce3b7d85287e03ffd68a";
    sha256 = "sha256-JO/kpnRO+X5VwaN5zCIr8mGg/4RtEFqNfT0ouUtJ27g=";
  };
  # patches = [ ./0001-bs-loosen-tomlkit-dep-version-constraint.patch ];

  buildInputs = [
    poetry
    python3Packages.poetry-core
  ];
  propagatedBuildInputs = with python3Packages; [
    halo
    ptpython
    click
    pyinotify
    pexpect
    psutil
    pyyaml
    execo
    requests
    tomlkit
    setuptools
  ] ++ [
    taktuk
  ];

  doCheck = false;

  meta = with lib; {
    description = "NixOS Compose";
    homepage = "https://gitlab.inria.fr/nixos-compose/nixos-compose";
    platforms = platforms.all;
    license = licenses.lgpl3;

    longDescription = "NixOS Compose";
  };
}
