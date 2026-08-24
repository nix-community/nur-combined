{
  fetchFromGitHub,
  lib,
  nix-update-script,
  python3,
  python3Packages,
  makeWrapper,
  stdenv,
}:
let
  pyenet = python3Packages.buildPythonPackage {
    pname = "cockpy-pyenet";
    version = "0-unstable-2022-11-20";
    pyproject = true;

    src = fetchFromGitHub {
      owner = "lilmayofuksu";
      repo = "pyenet";
      rev = "1726b1d8e22ee1fa53c7560169d8814c7847a447";
      fetchSubmodules = true;
      hash = "sha256-YzFge0S5S6TwCVeCuNgDUmDpwha7Zi8+ZgJ4cdW4AzM=";
    };
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
stdenv.mkDerivation (finalAttrs: {
  pname = "cockpy";
  version = "0-unstable-2024-09-07";
  src = fetchFromGitHub {
    owner = "Hiro420";
    repo = "CockPY";
    rev = "4813219045224b39463cb619a852c298603b2a30";
    hash = "sha256-1yvUD/aXX9ncj6StZQgz+PMqnelgcTyvhD8to0KKuXk=";
  };
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Public and open source version of the cbt2 ps I'm working on";
    homepage = "https://github.com/Hiro420/CockPY";
    license = with lib.licenses; [ unfreeRedistributable ];
    mainProgram = "cockpy";
  };
})
