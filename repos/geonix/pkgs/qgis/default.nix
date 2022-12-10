{ lib, makeWrapper, symlinkJoin
, extraPythonPackages ? (ps: [ ])
, libsForQt5
, qgis-unwrapped
}:
with lib;

symlinkJoin rec {

  inherit (qgis-unwrapped) version;
  name = "qgis-${version}";

  paths = [ qgis-unwrapped ];

  nativeBuildInputs = [ makeWrapper qgis-unwrapped.py.pkgs.wrapPython ];

  # extend to add to the python environment of QGIS without rebuilding QGIS application.
  pythonInputs = qgis-unwrapped.pythonBuildInputs ++ (extraPythonPackages qgis-unwrapped.py.pkgs);

  postBuild = ''
    # unpackPhase

    buildPythonPath "$pythonInputs"

    wrapProgram $out/bin/qgis \
      --prefix PATH : $program_PATH \
      --set PYTHONPATH $program_PYTHONPATH
  '';

  passthru.unwrapped = qgis-unwrapped;

  meta = qgis-unwrapped.meta;

  # FIXME: this setting allows qgis to appear in ci.nix cacheOutputs. It shouldn't be needed.
  # This behaviour might be caused by symlinkJoin.
  # See: https://github.com/NixOS/nixpkgs/blob/cf7f4393f3f953faf5765c7a0168c6710baa1423/pkgs/build-support/trivial-builders.nix#L440
  preferLocalBuild = false;
}
