{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  colorama,
  pytest,
}:
buildPythonPackage rec {
  pname = "backtrace";
  version = "0.2.1+";
  src = fetchFromGitHub {
    owner = "nir0s";
    repo = "backtrace";
    rev = "a1f75c956f669a6175088693802d5392e6bd7e51";
    sha256 = "1i3xj04zxz9vi57gbkmnnyh9cypf3bm966ic685s162p1xhnz2qp";
  };

  doCheck = false;

  prePatch = ''
    touch LICENSE
  '';

  propagatedBuildInputs = [colorama];

  buildInputs = [pytest];

  meta = with lib; {
    homepage = "https://github.com/nir0s/backtrace";
    license = licenses.asl20;
    # maintainers = [maintainers.drmikecrowe];
    description = "Makes Python tracebacks human friendly";
  };
}
