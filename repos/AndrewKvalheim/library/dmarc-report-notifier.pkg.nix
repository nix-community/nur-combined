{ fetchFromGitea
, gitUpdater
, lib
, python313Packages
}:

let
  inherit (lib) licenses;
  inherit (import ../library/utilities.lib.nix { inherit lib; }) versionsSatisfied;
in
python313Packages.buildPythonApplication rec {
  pname = "dmarc-report-notifier";
  version = "1.1.13";
  meta = {
    description = "Headless periodic DMARC report handler";
    homepage = "https://codeberg.org/AndrewKvalheim/dmarc-report-notifier";
    license = licenses.gpl3;
    mainProgram = "dmarc-report-notifier";
    broken = with python313Packages; ! versionsSatisfied [
      [ parsedmarc "≥9.6.0,<10" ]
    ];
  };

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "AndrewKvalheim";
    repo = "dmarc-report-notifier";
    rev = "refs/tags/v${version}";
    hash = "sha256-F/bTSqfZEvTS4rFkjDVjYj59ck5BZ2fzN0crexPGpB4=";
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
}
