{ lib
, buildPythonPackage
, fetchFromGitHub
, cmake
}:

buildPythonPackage rec {
  pname = "oead";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "zeldamods";
    repo = pname;
    rev = "v${version}";
    sha256 = "04dmd88jxly42d7kcqbdraadhcysrvzmcivamg9sshbc187a8d0w";
    fetchSubmodules = true;
  };

  postPatch = ''
    # Use nixpkgs version instead of versioneer
    substituteInPlace setup.py \
      --replace "cmdclass = versioneer.get_cmdclass()" "cmdclass = {}" \
      --replace "version=versioneer.get_version()" "version='${version}'"
  '';

  nativeBuildInputs = [ cmake ];
  dontUseCmakeConfigure = true;

  meta = with lib; {
    description = "Library for recent Nintendo EAD formats in first-party games";
    homepage = "https://github.com/zeldamods/oead";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ metadark ];
  };
}
