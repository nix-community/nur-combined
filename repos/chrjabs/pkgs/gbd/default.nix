{
  lib,
  python,
  fetchFromGitHub,
  setuptools,
  wheel,
  gbdc,
}:
python.pkgs.buildPythonPackage rec {
  pname = "gbd-tools";
  version = "5.2.0+multi-opt";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbd";
    rev = "92fac125b337c2e1582e133ddc61219ce6bc109d";
    hash = "sha256-hxvhs7Z4oZnCjP9KV5hyxhqqQ57+HOtAvU0xSWtMOAw=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "5.2.0"' 'version = "5.2.0+multi-opt"'
  '';

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
