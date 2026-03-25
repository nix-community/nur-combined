{
  maintainers,
  lib,
  fetchFromGitHub,
  python3Packages,
  ffmpeg,
  ...
}:
let
  pname = "ld-decode";
  version = "7.2.0";

  rev = "v${version}";
  hash = "sha256-rcpgY6JhMJUfido6giP9oDpzyMQM4r4G/Qmhkky3vNk=";

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
