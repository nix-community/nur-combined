{
  stdenv,
  lib,
  fetchFromGitHub,
  python3,
  python3Packages,
  pkg-config,
  meson,
  ninja,
  libslimbook,
}:

python3Packages.buildPythonPackage rec {
  pname = "python-slimbook";
  version = "0-unstable-2024-12-05";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "Slimbook-Team";
    repo = "python-slimbook";
    rev = "009ee634058c2d9bcc870cff40c1552e91e101b4";
    hash = "sha256-P4tBK6DCLw3c9zd8AW0nvG/cdDAbmpUJ7STbp3E/b54=";
  };
  postPatch = ''
    # Fix license
  '';
  build-system = [
    python3Packages.setuptools
    # libslimbook # Does this work? Need at runtime
    # python3
  ];
  nativeBuildInputs = with python3Packages; [
    setuptools
  ];
  propagatedBuildInputs = [
    python3Packages.pygobject3
    libslimbook
  ];

  meta = {
    # broken = true;
    description = "Python bindings for libslimbook";
    homepage = "https://github.com/Slimbook-Team/python-slimbook";
    license = lib.licenses.lgpl3Plus;
    # maintainers = with lib.maintainers; [ lucasfa ];
  };
}
