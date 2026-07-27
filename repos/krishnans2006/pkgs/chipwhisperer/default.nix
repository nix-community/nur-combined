{
  lib,
  python312,
  fetchFromGitHub,
  udevCheckHook,
  writableTmpDirAsHomeHook,
}:

# Usage:
# In NixOS, add the package to services.udev.packages for non-root plugdev
# users to get device access permission:
#    services.udev.packages = [ chipwhisperer ];

let
  # ChipWhisperer requires NumPy 1.x (numpy==1.26.4 in its requirements.txt),
  # which is why the upstream nixpkgs package is marked broken. NumPy 1.x is
  # packaged as `numpy_1`, but it is only buildable on Python <= 3.12. So we
  # build ChipWhisperer in a Python 3.12 package set where `numpy` is overridden
  # to `numpy_1`, ensuring the package and all of its dependencies use NumPy 1.
  python = python312.override {
    self = python;
    packageOverrides = _final: prev: {
      numpy = prev.numpy_1;
    };
  };
in
python.pkgs.buildPythonPackage rec {
  pname = "chipwhisperer";
  version = "5.7.0";

  src = fetchFromGitHub {
    owner = "newaetech";
    repo = "chipwhisperer";
    tag = version;
    hash = "sha256-C7QP044QEP7vmz1lMseLtMTYoKn5SoFV/q9URY7yQ6I=";
  };

  pyproject = true;

  build-system = with python.pkgs; [
    setuptools
    setuptools-scm
  ];

  nativeBuildInputs = with python.pkgs; [
    cython
  ];

  dependencies = with python.pkgs; [
    colorama
    configobj
    ecpy
    fastdtw
    libusb1
    numpy
    pyserial
    tqdm
  ];

  nativeInstallCheckInputs = [
    udevCheckHook
  ];

  postInstall = ''
    # Install udev rules
    # The 50-newae.rules file from the repo isn't directly installed, since it
    # installs to the chipwhisperer group (and not to uaccess)

    mkdir -p $out/etc/udev/rules.d

    cat <<EOF > $out/etc/udev/rules.d/50-newae.rules
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", TAG+="uaccess"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2b3e", ATTRS{idProduct}=="*", TAG+="uaccess", SYMLINK+="cw_serial%n"
    SUBSYSTEM=="tty", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", TAG+="uaccess", SYMLINK+="cw_bootloader%n"
    EOF
  '';

  pythonImportsCheck = [ "chipwhisperer" ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    python.pkgs.pytestCheckHook
  ];

  enabledTestPaths = [
    # All other tests require connected hardware
    # Error: "Could not find ChipWhisperer. Is it connected?"
    # See: https://chipwhisperer.readthedocs.io/en/latest/contributing.html#unit-tests
    "tests/test_api.py"
  ];

  disabledTests = [ "TestCPA" ]; # Tries to open a tutorial project

  meta = {
    description = "Toolchain for side-channel power analysis and glitching attacks";
    homepage = "https://github.com/newaetech/chipwhisperer";
    changelog = "https://github.com/newaetech/chipwhisperer/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.krishnans2006 ];
  };
}
