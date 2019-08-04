{ lib, fetchFromGitHub
, python3, python3Packages
}:

let
  deps = with python3Packages; [
    sympy numpy pint django_1_11 mpmath dateutil colorama
  ];
  pythonEnv = python3.withPackages (p: deps);
in
  python3Packages.buildPythonApplication rec {
    pname = "mathics";
    version = "1.0";

    src = fetchFromGitHub {
      owner = "mathics";
      repo = "Mathics";
      rev = "0f2049586db6d42d6ae372afd6d65c4b6ddc883d";
      sha256 = "18v2yspvf7cjm30k4d9gv3d7d4nhp53rxlhxcwbiy3g4zf32b4zg";
    };

    propagatedBuildInputs = deps;

    postPatch = ''
      substituteInPlace mathics/server.py \
        --replace "sys.executable, " ""
    '';

    doCheck = false;

    postInstall = ''
      for manage in $(find $out -name manage.py); do
        chmod +x $manage
        wrapProgram $manage --set PYTHONPATH "$PYTHONPATH:${pythonEnv}/${pythonEnv.sitePackages}"
      done
    '';

    disabled = !python3Packages.isPy3k;
    meta = {
      broken = true;

      description = "A free, light-weight alternative to Mathematica";
      homepage = https://mathics.github.io/;
      license = lib.licenses.gpl3;
      maintainers = [ lib.maintainers.suhr ];
    };
  }
