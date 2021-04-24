{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
}:

buildPythonPackage rec {
  pname = "oead";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-XW6KRCexNXzMdidkH4UyVncDe+v1qvTYp76TtyRg3Lo=";
  };

  postPatch = ''
    # Use nixpkgs version instead of versioneer
    substituteInPlace setup.py \
      --replace "cmdclass = versioneer.get_cmdclass()" "cmdclass = {}" \
      --replace "version=versioneer.get_version()" "version='${version}'"
  '';

  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;
  pythonImportsCheck = [ "oead" ];

  meta = with lib; {
    description = "Library for recent Nintendo EAD formats in first-party games";
    homepage = "https://github.com/zeldamods/oead";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
