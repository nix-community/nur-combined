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
  version = "5.0.0-multi-opt";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbd";
    rev = "1babdb3173b1093ea6299ae04bf2380e942fed1b";
    hash = "sha256-ziWYM72mXwzwAsxvNKq03yujlB4+baNbjjAYFOwfu4Q=";
  };

  build-system = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = with python.pkgs; [
    flask
    tatsu
    polars
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
