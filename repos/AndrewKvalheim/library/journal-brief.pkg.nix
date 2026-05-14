{ fetchPypi
, lib
, nix-update-script
, python3Packages
}:

let
  inherit (lib) escapeShellArg licenses;
in
python3Packages.buildPythonApplication rec {
  pname = "journal-brief";
  version = "1.1.8";
  meta = {
    description = "Show interesting new systemd journal entries since last run";
    homepage = "https://github.com/twaugh/journal-brief";
    license = licenses.gpl2Only;
    mainProgram = "journal-brief";
  };

  passthru.updateScript = nix-update-script { };

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-lY1U5dcRVl/79IEz/l0KN4SAlQs9djIK/VN47TfPdhE=";
  };

  format = "pyproject";
  nativeBuildInputs = with python3Packages; [
    setuptools
  ];
  dependencies = with python3Packages; [
    pyyaml
    systemd-python
  ];

  doInstallCheck = true;
  # Pending compatibility with versionCheckHook
  installCheckPhase = ''
    help="$($out/bin/${escapeShellArg meta.mainProgram} --help)"
    echo "$help"
    [[ "$help" == *'usage: journal-brief'* ]]
    [[ "$help" != *'version'* ]]
    [[ "$help" != *${escapeShellArg version}* ]]
  '';
}
