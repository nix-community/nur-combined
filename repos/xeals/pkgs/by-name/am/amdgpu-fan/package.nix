{ lib
, fetchFromGitHub

, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "amdgpu-fan";
  version = "0.0.6";

  src = fetchFromGitHub {
    repo = pname;
    owner = "chestm007";
    rev = version;
    sha256 = "1ngfrk6agk8wz0q9426lwrqhbgxc98hrsv0kn6wgz25j1rv9332b";
  };

  propagatedBuildInputs = with python3Packages; [
    numpy
    pyyaml
  ];

  format = "setuptools";

  patchPhase = ''
    substituteInPlace setup.py \
      --replace PROJECTVERSION "${version}"
  '';

  meta = with lib; {
    description = "Fan controller for AMD graphics cards running the amdgpu driver on Linux";
    homepage = "https://github.com/chestm007/amdgpu-fan";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
