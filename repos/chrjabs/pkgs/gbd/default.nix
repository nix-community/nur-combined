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
  version = "5.3.0+multi-opt";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chrjabs";
    repo = "gbd";
    rev = "c5223a10e1af1a442e1cc7a615c9c0004fabaa3f";
    hash = "sha256-v44r0yqQRYGdESyX5kL3USNj6s87y1dbejOy1L7HDkM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'version = "5.3.0"' 'version = "5.3.0+multi-opt"'
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
