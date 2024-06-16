{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "osmwalkthrough";
  version = "0-unstable-2021-09-24";
  format = "other";

  src = fetchFromGitHub {
    owner = "leotrubach";
    repo = "osmwalkthrough";
    rev = "e96bbfd1e0465d7447c51056f5845da251b50cff";
    hash = "sha256-M727uDMHBkBie2g6Cl5QPGwQtcAnC3goJ9qM8VVEoUU=";
  };

  dontUseSetuptoolsBuild = true;
  doCheck = false;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (
        p: with p; [
          geographiclib
          geopy
          networkx
        ]
      );
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/solver \
        --add-flags "$site_packages/solver.py"
    '';

  meta = {
    description = "Draw ways you want to walk through";
    homepage = "https://github.com/leotrubach/osmwalkthrough";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
