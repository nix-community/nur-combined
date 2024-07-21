{
  buildPythonPackage,
  fetchFromGitHub,
  backtrace,
  lib,
}:
buildPythonPackage rec {
  pname = "xontrib-readable-traceback";
  version = "0.4.0";
  src = fetchFromGitHub {
    owner = "vaaaaanquish";
    repo = "xontrib-readable-traceback";
    rev = version;
    sha256 = "sha256-ek+GTWGUpm2b6lBw/7n4W46W2R0Gy6JxqWoLuQilCXQ=";
  };

  doCheck = false;

  propagatedBuildInputs = [backtrace];
  prePatch = ''
    substituteInPlace xontrib/readable-traceback.xsh \
            --replace 'sys.stderr.write(msg)' '__flush(msg)'
  '';

  meta = with lib; {
    homepage = "https://github.com/vaaaaanquish/xontrib-readable-traceback";
    license = licenses.mit;
    # maintainers = [maintainers.drmikecrowe];
    description = "Make traceback easier to see for the [xonsh shell](https://xon.sh)..";
  };
}
