{
  lib,
  fetchFromGitHub,
  meson,
  ninja,
  buildPythonPackage,
  pytestCheckHook,
  pkg-config,
  cairo,
  python,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycairo";
  version = "1.18.2";

  format = "other";

  src = fetchFromGitHub {
    owner = "pygobject";
    repo = "pycairo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-0igF4s8T8OvdAlL7y6+uP+Ml4nAryyhFmnRDLlQhQZA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cairo
  ];

  checkInputs = [
    pytestCheckHook
  ];

  mesonFlags = [
    # This is only used for figuring out what version of Python is in
    # use, and related stuff like figuring out what the install prefix
    # should be, but it does need to be able to execute Python code.
    "-Dpython=${python.pythonOnBuildForHost.interpreter}"
  ];

  meta = with lib; {
    description = "Python 2 bindings for cairo";
    homepage = "https://pycairo.readthedocs.io/";
    license = with licenses; [
      lgpl21Only
      mpl11
    ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
