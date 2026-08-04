{ fetchFromCodeberg
, gitUpdater
, lib
, python313Packages
}:

let
  inherit (lib) licenses;
  inherit (import ../library/utilities.lib.nix { inherit lib; }) versionsSatisfied;
in
python313Packages.buildPythonApplication (dmarc-report-notifier: {
  pname = "dmarc-report-notifier";
  version = "1.1.15";
  meta = {
    description = "Headless periodic DMARC report handler";
    homepage = "https://codeberg.org/AndrewKvalheim/dmarc-report-notifier";
    license = licenses.gpl3;
    mainProgram = "dmarc-report-notifier";
    broken = with python313Packages; ! versionsSatisfied [
      [ parsedmarc "≥10.2.0,<11" ]
    ];
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromCodeberg {
    owner = "AndrewKvalheim";
    repo = "dmarc-report-notifier";
    rev = "refs/tags/v${dmarc-report-notifier.version}";
    hash = "sha256-p2In3wJTO7dlnb1IjxY6MP3g4+JnXe1F5aDdt7xRU8c=";
  };

  format = "pyproject";
  nativeBuildInputs = with python313Packages; [
    hatchling
  ];
  dependencies = with python313Packages; [
    jinja2
    jinja2-pluralize
    matrix-nio
    parsedmarc
  ];
})
