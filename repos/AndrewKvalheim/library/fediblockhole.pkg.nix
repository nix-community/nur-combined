{ fetchPypi
, lib
, python3Packages
, versionCheckHook
}:

let
  inherit (builtins) placeholder;
  inherit (lib) licenses;
in
python3Packages.buildPythonApplication rec {
  pname = "fediblockhole";
  version = "0.4.6";
  meta = {
    description = "Tool for automatically syncing Mastodon admin domain blocks";
    homepage = "https://github.com/eigenmagic/fediblockhole";
    license = licenses.agpl3Only;
    mainProgram = "fediblock-sync";
  };

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-zqwvAF0mskQKIcW7pQ/f1jjTe1RJjonaIyKaqvcH+1k=";
  };

  format = "pyproject";
  nativeBuildInputs = with python3Packages; [
    hatchling
  ];
  dependencies = with python3Packages; [
    requests
    toml
  ];

  nativeCheckInputs = [ versionCheckHook ]; # Pending nixos/nixpkgs#420531
  versionCheckProgram = "${placeholder "out"}/bin/${meta.mainProgram}";
}
