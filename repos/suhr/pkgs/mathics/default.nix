{ lib, fetchFromGitHub
, python3, python3Packages
, stdenv, substituteAll
}:

let
  dj = python3Packages.buildPythonPackage rec {
    pname = "Django";
    version = "3.1.2";

    src = python3Packages.fetchPypi {
      inherit pname version;
      sha256 = "1k041dn51yhsvar3srb1dp47qsgrpzdibpxyamk9dihf2p87l4m2";
    };

    propagatedBuildInputs = with python3Packages; [ pytz sqlparse asgiref ];

    # too complicated to setup
    doCheck = false;

    meta = with stdenv.lib; {
      description = "A high-level Python Web framework";
      homepage = "https://www.djangoproject.com/";
      license = licenses.bsd3;
      maintainers = with maintainers; [ georgewhewell lsix ];
    };
  };
  deps = with python3Packages; [
    sympy numpy pint dj mpmath dateutil colorama pydot llvmlite requests palettable setuptools
  ];
  pythonEnv = python3.withPackages (p: deps);
in
  python3Packages.buildPythonApplication rec {
    pname = "mathics";
    version = "1.0";

    src = fetchFromGitHub {
      owner = "mathics";
      repo = "Mathics";
      rev = "e569648a1522ddb468e6a03d2b4996f06ae6b457";
      sha256 = "0jlrdh4b3acwijrw4njzgz3shzr92f6amq8ghzr96lzd865h9xis";
    };

    propagatedBuildInputs = deps;

    postPatch = ''
      substituteInPlace mathics/server.py \
        --replace "sys.executable, " ""
    '';

    doCheck = false;

    # postBuild = ''
    #   python mathics/test.py -o
    # '';

    postInstall = ''
      SANDBOX=true python mathics/test.py -o
      for manage in $(find $out -name manage.py); do
        chmod +x $manage
        wrapProgram $manage --set PYTHONPATH "$PYTHONPATH:${pythonEnv}/${pythonEnv.sitePackages}"
      done
    '';

    disabled = !python3Packages.isPy3k;
    meta = {
      broken = false;

      description = "A free, light-weight alternative to Mathematica";
      homepage = https://mathics.github.io/;
      license = lib.licenses.gpl3;
      maintainers = [ lib.maintainers.suhr ];
    };
  }
