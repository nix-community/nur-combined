{ fetchFromCodeberg
, gitUpdater
, lib
, python3Packages
}:

let
  inherit (lib) licenses;
  inherit (import ../library/utilities.lib.nix { inherit lib; }) versionsSatisfied;
in
python3Packages.buildPythonApplication (dmarc-report-notifier: {
  pname = "dmarc-report-notifier";
  version = "1.1.16";
  meta = {
    description = "Headless periodic DMARC report handler";
    homepage = "https://codeberg.org/AndrewKvalheim/dmarc-report-notifier";
    license = licenses.gpl3;
    mainProgram = "dmarc-report-notifier";
    broken = with python3Packages; ! versionsSatisfied [
      [ matrix-nio "≥0.24,<0.27" ]
      [ parsedmarc "≥10.2.0,<11" ]
    ];
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromCodeberg {
    owner = "AndrewKvalheim";
    repo = "dmarc-report-notifier";
    rev = "refs/tags/v${dmarc-report-notifier.version}";
    hash = "sha256-NTss/KIiK1LnH4TImMdE5FziUcK8xqf7pItmDc6yRhE=";
  };

  format = "pyproject";
  nativeBuildInputs = with python3Packages; [
    hatchling
  ];
  dependencies = with python3Packages; [
    jinja2
    jinja2-pluralize
    matrix-nio
    parsedmarc
  ];
})
