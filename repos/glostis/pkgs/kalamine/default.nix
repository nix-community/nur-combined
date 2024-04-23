{ lib
, fetchPypi
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "kalamine";
  version = "0.36";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-OpaWlm9LDBB4fGmmVo44h7amce1Nuvth8w2ogrditvc=";
  };

  nativeBuildInputs = [
    python3Packages.hatchling
  ];

  propagatedBuildInputs = with python3Packages; [
    click
    livereload
    pyyaml
    tomli
    progress
  ];

  meta = with lib; {
    description = "A cross-platform Keyboard Layout Maker";
    homepage = "https://github.com/OneDeadKey/kalamine";
    license = licenses.mit;
    # To fill in if pushed to Nixpkgs
    # maintainers = with maintainers; [ ];
    mainProgram = "kalamine";
  };
}
