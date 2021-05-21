{ buildPythonPackage, lib, fetchFromGitHub, gfortran
, makeWrapper, numpy, pytest, mock, pytest-mock
} :

buildPythonPackage rec {
  name = "i-PI";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "i-pi";
    repo = "i-pi";
    rev = "v${version}";
    sha256 = "18aavj2x5vxl2i8ssk757rnbi6hygqpf4nsppxjjpmwjb7lw1ad3";
  };

  nativeBuildInputs = [
    gfortran
    makeWrapper
  ];

  propagatedBuildInputs = [ numpy ];

  checkInputs = [
    pytest
    mock
    pytest-mock
  ];

  postFixup = ''
    wrapProgram $out/bin/i-pi \
      --set IPI_ROOT $out
  '';

  meta = with lib; {
    description = "A universal force engine";
    license = licenses.gpl3Only;
    homepage = "http://ipi-code.org/";
    platforms = platforms.linux;
  };
}
