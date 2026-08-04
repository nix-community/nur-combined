{ fetchPypi
, lib
, nix-update-script
, python3Packages
, versionCheckHook

  # Dependencies
, yaralyzer
}:

let
  inherit (lib) licenses;
  inherit (import ../library/utilities.lib.nix { inherit lib; }) versionsSatisfied;
in
python3Packages.buildPythonApplication (pdfalyzer: {
  pname = "pdfalyzer";
  version = "1.19.6";
  meta = {
    description = "Analyze PDFs with colors (and YARA)";
    homepage = "https://github.com/michelcrypt4d4mus/pdfalyzer";
    license = licenses.gpl3Only;
    mainProgram = "pdfalyze";
    broken = with python3Packages; ! versionsSatisfied [
      [ pypdf "6.6.0" ]
      [ yaralyzer "1.3.17" ]
    ];
  };

  passthru.updateScript = nix-update-script { };

  src = fetchPypi {
    inherit (pdfalyzer) pname version;
    hash = "sha256-iI3zJS9z/igTKgF4JLxg96aGxqBYAPOwJvdvSO5lXdM=";
  };

  format = "pyproject";
  build-system = with python3Packages; [ poetry-core ];
  dependencies = with python3Packages; [
    anytree
    pypdf
    yaralyzer
  ];

  nativeCheckInputs = [ versionCheckHook ]; # Pending nixos/nixpkgs#420531
})
