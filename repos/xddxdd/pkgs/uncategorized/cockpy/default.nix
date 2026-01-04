{
  lib,
  sources,
  python3,
  python3Packages,
  makeWrapper,
  stdenv,
}:
let
  pyenet = python3Packages.buildPythonPackage {
    inherit (sources.cockpy-pyenet) pname version src;
    pyproject = true;
    build-system = [ python3Packages.setuptools ];

    propagatedBuildInputs = with python3Packages; [ cython ];

    doCheck = false;
  };

  pythonEnv = python3.withPackages (
    ps: with ps; [
      (betterproto.overridePythonAttrs (_old: {
        doCheck = false;
      }))
      bottle
      colorama
      cython
      loguru
      lupa
      pandas
      pyenet
      setuptools
    ]
  );
in
stdenv.mkDerivation {
  inherit (sources.cockpy) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    sed -i "/logfile/d" game_server/__init__.py
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt

    cp -r * $out/opt/

    makeWrapper ${lib.getExe pythonEnv} $out/bin/cockpy \
      --prefix PYTHONPATH : "$out/opt" \
      --add-flags "-m" \
      --add-flags "cockpy"

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Public and open source version of the cbt2 ps im working on";
    homepage = "https://github.com/Hiro420/CockPY";
    license = with lib.licenses; [ unfreeRedistributable ];
    mainProgram = "cockpy";
  };
}
