{
  pkgs,
  python3,
}: let
  backtrace = python3.pkgs.buildPythonPackage rec {
    pname = "backtrace";
    version = "0.2.1+";
    src = pkgs.fetchFromGitHub {
      owner = "nir0s";
      repo = "backtrace";
      rev = "a1f75c956f669a6175088693802d5392e6bd7e51";
      sha256 = "1i3xj04zxz9vi57gbkmnnyh9cypf3bm966ic685s162p1xhnz2qp";
    };
    meta = {
      homepage = "https://github.com/nir0s/backtrace";
      license = pkgs.lib.licenses.asl20;
      description = "Makes Python tracebacks human friendly";
    };
    prePatch = ''
      touch LICENSE
    '';
    propagatedBuildInputs = [pkgs.python3Packages.colorama];
    buildInputs = [pkgs.python3Packages.pytest];
  };
in
  python3.pkgs.buildPythonPackage rec {
    pname = "xontrib-readable-traceback";
    version = "0.4.0";
    src = pkgs.fetchFromGitHub {
      owner = "vaaaaanquish";
      repo = "xontrib-readable-traceback";
      rev = version;
      sha256 = "sha256-ek+GTWGUpm2b6lBw/7n4W46W2R0Gy6JxqWoLuQilCXQ=";
    };
    meta = {
      homepage = "https://github.com/vaaaaanquish/xontrib-readable-traceback";
      license = pkgs.lib.licenses.mit;
      description = "Make traceback easier to see for xonsh.";
    };
    propagatedBuildInputs = [backtrace];
    prePatch = ''
      substituteInPlace xontrib/readable-traceback.xsh \
              --replace 'sys.stderr.write(msg)' '__flush(msg)'
    '';
  }
