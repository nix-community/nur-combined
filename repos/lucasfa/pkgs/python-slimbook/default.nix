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
  version = "1.19.0";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "Slimbook-Team";
    repo = pname;
    tag = version;
    hash = "sha256-J2bk2kDuhhRrwnhyTcA0jkCU8VcEfw5njL7FlNBOij4=";
  };

  postPatch = ''
substituteInPlace \
  slimbook/info/__init__.py \
  slimbook/config/__init__.py \
  slimbook/kbd/__init__.py \
  slimbook/smbios/__init__.py \
  slimbook/qc71/__init__.py \
    --replace-fail '_libslimbook = ctypes.CDLL("libslimbook.so.1")' '_libslimbook = ctypes.CDLL("${libslimbook}/lib/slimbook.so.1")'
  '';

  build-system = [
    python3Packages.setuptools
    # python3
  ];
  nativeBuildInputs = with python3Packages; [
    setuptools
  ];
  propagatedBuildInputs = [
    python3Packages.pygobject3
    libslimbook
  ];
  postInstall = ''
    find $out -name "__pycache__" -type d | xargs rm -rv
'';


  meta = {
    # broken = true;
    description = "Python bindings for libslimbook";
    homepage = "https://github.com/Slimbook-Team/python-slimbook";
    license = lib.licenses.lgpl3Plus;
    # maintainers = with lib.maintainers; [ lucasfa ];
  };
}
