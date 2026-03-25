{
  maintainers,
  lib,
  fetchFromGitHub,
  python3Packages,
  ffmpeg,
  ...
}:
let
  pname = "ld-decode-unstable";
  version = "7.2.0-unstable-2026-03-25";

  rev = "fdad0dfdaabb480310e3acdf86ed48ed463d6105";
  hash = "sha256-QaoeMSj8oVUXRBZip/bG4FRP4iZEP67Tdhe1bJizyok=";

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "oyvindln";
    repo = "vhs-decode";
  };
in
python3Packages.buildPythonPackage {
  inherit pname version src;

  pyproject = true;

  SETUPTOOLS_SCM_PRETEND_VERSION = (
    (lib.strings.removeSuffix "-unstable" (lib.strings.getName version))
    + "+"
    + (builtins.substring 0 7 rev)
  );

  build-system = [
    python3Packages.setuptools
    python3Packages.setuptools-scm
  ];

  buildInputs = [
    ffmpeg
  ];

  propagatedBuildInputs = [
    python3Packages.av
    python3Packages.matplotlib
    python3Packages.numba
    python3Packages.numpy
    python3Packages.scipy
  ];

  pythonImportsCheck = [
    "lddecode"
  ];

  meta = {
    inherit maintainers;
    description = "Software defined LaserDisc decoder.";
    homepage = "https://github.com/happycube/ld-decode";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainprogram = "ld-decode";
  };
}
