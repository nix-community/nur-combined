{
  lib,
  sources,
  python3,
  python3Packages,
  makeWrapper,
  ...
}:
with python3Packages;
let
  pyenet = buildPythonPackage {
    inherit (sources.cockpy-pyenet) pname version src;

    propagatedBuildInputs = [ cython ];

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

    makeWrapper ${pythonEnv}/bin/python $out/bin/cockpy \
      --prefix PYTHONPATH : "$out/opt" \
      --add-flags "-m" \
      --add-flags "cockpy"

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "public and open source version of the cbt2 ps im working on ";
    homepage = "https://github.com/Hiro420/CockPY";
    license = with licenses; [ unfreeRedistributable ];
  };
}
