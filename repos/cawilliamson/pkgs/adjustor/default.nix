{
  fetchFromGitHub,
  lib,
  python3Packages,
  kmod,
  util-linux,
  ...
}:

python3Packages.buildPythonPackage rec {
  pname = "adjustor";
  version = "3.11.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hhd-dev";
    repo = "adjustor";
    rev = "v${version}";
    sha256 = "sha256-5E3I/PTukDTIZSF8tv7C+zjdXr0Sl4M5UY1FHWrbOhc=";
  };

  # This package relies on several programs expected to be on the user's PATH.
  # We take a more reproducible approach by patching the absolute path to each of these required
  # binaries.
  postPatch = ''
    substituteInPlace src/adjustor/core/acpi.py \
      --replace-fail '"modprobe"' '"${lib.getExe' kmod "modprobe"}"'
    substituteInPlace src/adjustor/fuse/utils.py \
      --replace-fail 'f"mount' 'f"${lib.getExe' util-linux "mount"}'
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    rich
    pyroute2
    fuse
    pygobject3
    dbus-python
    kmod
  ];

  # This package doesn't have upstream tests.
  doCheck = false;

  meta = {
    homepage = "https://github.com/hhd-dev/adjustor/";
    description = "Adjustor TDP plugin for Handheld Daemon";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ toast ];
    mainProgram = "hhd";
  };
}
