{
  lib,
  fetchFromGitHub,
  makeWrapper,
  python3,
  pkgs,
  fitcsvtool ? (pkgs.callPackage ../fitcsvtool {}),
  gpxpy ? python3.pkgs.gpxpy,
  srtmpy ? (pkgs.callPackage ../srtmpy {inherit (python3.pkgs) buildPythonPackage requests;}),
}: let
  makePythonPath = python3.pkgs.makePythonPath;
in
  python3.pkgs.buildPythonApplication {
    pname = "gpxtofitconverter";
    version = "HEAD-2025-03-02";
    src = fetchFromGitHub {
      owner = "googol42";
      repo = "GpxToFitConverter";
      rev = "d22b62345cef58c97a336ed998b486fe17c4bc93";
      hash = "sha256-SX9bkz6V4WJKGkOLn06wbatVcPfUNfZhYtrKKkg0gok=";
    };

    format = "other";

    nativeBuildInputs = [makeWrapper];

    buildInputs = [
      gpxpy
      srtmpy
    ];

    patches = [./patches/hardcoded-jar.patch];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib/gpxtofitconverter
      cp -r src/* $out/lib/gpxtofitconverter/

      mkdir -p $out/bin

      # Compute PYTHONPATH manually based on the deps
      pyDeps="${makePythonPath [gpxpy srtmpy]}"

      makeWrapper ${python3.interpreter} $out/bin/gpxtofitconverter \
        --add-flags "$out/lib/gpxtofitconverter/convertGpxToFit.py" \
        --prefix PYTHONPATH : "$pyDeps:$out/lib/gpxtofitconverter" \
        --prefix PATH : ${lib.makeBinPath [fitcsvtool]}

      runHook postInstall
    '';

    # don't build in CI, depends on unfree Garmin SDK
    preferLocalBuild = true;

    meta = {
      license = lib.licenses.gpl3Only;
      homepage = "https://github.com/googol42/GpxToFitConverter";
      description = "Python Script to Convert GPX files into FIT files";
    };
  }
