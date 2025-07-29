{
  lib,
  python,
  fetchFromGitHub,
  setuptools,
  wheel,
  gbdc,
}:
python.pkgs.buildPythonPackage rec {
  pname = "gbd";
  version = "4.9.11-multi-opt";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbd";
    rev = "8549bdb738bd8468dd34e6c5fd0308f8b3cf50ed";
    hash = "sha256-/5FxJcGFaNqm9xd0Sy7syUt5ecWxLQyzEuAYlMCdmhg=";
  };

  build-system = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python.pkgs; [
    flask
    tatsu
    pandas
    waitress
    pebble
    gbdc
    ipython
  ];

  pythonImportsCheck = [
    "gbd"
    "gbd_core"
    "gbd_init"
    "gbd_server"
  ];

  meta = {
    description = "Management of Benchmark Instances and Instance Attributes";
    homepage = "https://github.com/udopia/gbd";
    license = lib.licenses.mit;
    maintainers = [ (import ../../maintainer.nix { inherit (lib) maintainers; }) ];
    mainProgram = "gbd";
  };
}
