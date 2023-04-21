{ lib, python3Packages, fetchFromGitLab, poetry, execo, taktuk }:

python3Packages.buildPythonPackage rec {
  pname = "nxc";
  version = "cluster22";
  format = "pyproject";

  src = fetchFromGitLab {
    domain = "gitlab.inria.fr";
    owner = "nixos-compose";
    repo = "nixos-compose";
    rev = "cluster22-pkg-kapack";
    sha256 = "sha256-Sqc4FF3yzBvbKFvlEYXmrCrh1AYfpcJv4vhiqN1K+Ws=";
  };
  patches = [ ./0001-bs-loosen-tomlkit-dep-version-constraint.patch ];

  buildInputs = with python3Packages; [
    poetry
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
  ] ++ [
    taktuk
  ];

  doCheck = false;

  meta = with lib; {
    description = "NixOS Compose";
    homepage = "https://gitlab.inria.fr/nixos-compose/nixos-compose";
    platforms = platforms.all;
    license = licenses.lgpl3;
    broken = false;

    longDescription = "NixOS Compose";
  };
}
