{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "gcgn-converter";
  version = "08.07.2023";
  format = "other";

  src = fetchFromGitHub {
    owner = "Miroff";
    repo = "gcgn-converter";
    rev = version;
    hash = "sha256-1ipBRQNMGb0wBAHxlJWoQEcaegR3wrlAw9YXUF4fkH8=";
  };

  dontUseSetuptoolsBuild = true;
  dontUseSetuptoolsCheck = true;

  installPhase =
    let
      pythonEnv = python3Packages.python.withPackages (
        p: with p; [
          camelot
          pypdf
          geojson
          beautifulsoup4
          tqdm
        ]
      );
    in
    ''
      site_packages=$out/lib/${python3Packages.python.libPrefix}/site-packages
      mkdir -p $site_packages
      cp *.py $site_packages

      makeWrapper ${pythonEnv.interpreter} $out/bin/gcgn_convert \
        --add-flags "$site_packages/gcgn_convert.py"
    '';

  meta = with lib; {
    description = "Ковертер ГКГН из PDF в GeoJSON";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = with maintainers; [ sikmir ];
  };
}
