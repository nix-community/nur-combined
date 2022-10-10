{ lib
, fetchFromGitHub
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "mbtiles2osmand";
  version = "2021-01-01";
  format = "other";

  src = fetchFromGitHub {
    owner = "tarwirdur";
    repo = "mbtiles2osmand";
    rev = "5084a6ff9c60794044a751cc62ef84b6e37a342e";
    hash = "sha256-vghESjT6Pklq7IjxTEIHfTxX2B3eCgUl9CP+eJntByA=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (p: with p; [
        pillow
      ]);
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/mbtiles2osmand \
        --add-flags "$site_packages/mbtiles2osmand.py"
      makeWrapper ${pythonEnv.interpreter} $out/bin/unite_osmand \
        --add-flags "$site_packages/unite_osmand.py"
    '';

  meta = with lib; {
    description = "Converts mbtiles format to sqlitedb format suitable for OsmAnd and RMaps";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
  };
}
