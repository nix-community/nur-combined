{ lib, stdenv, mkDerivation, fetchurl
}:

mkDerivation rec {
  version = "0.7.1";
  pname = "mirage";

  src = fetchFromGitHub {
    owner = "mirukana";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "0j7gdg2z8yg3qvwg9d9fa3i4ig231qda48p00s5gk8bc3c65vsll";
  };


  dontWrapQtApps = true;
  postInstall = ''
    buildPythonPath "$out $pythonPath"
    wrapProgram $out/bin/mirage \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      "''${qtWrapperArgs[@]}"
    '';


  meta = with lib; {
    homepage = "https://github.com/mirukana/mirage/";
    description =
      " A fancy, customizable, keyboard-operable Qt/QML+Python Matrix chat client for encrypted and decentralized communication.";
    license = licenses.lgpl3;
    # maintainers = with maintainers; [ zeratax ];
  };
}

