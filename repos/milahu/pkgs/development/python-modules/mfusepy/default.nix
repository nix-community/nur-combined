# based on https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/python-modules/fusepy/default.nix

{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  pkgs,
  pytestCheckHook,
  util-linux,
}:

buildPythonPackage rec {
  pname = "mfusepy";
  # note: this is newer than 2.0.4
  version = "1.1.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mxmlnkn";
    repo = "mfusepy";
    rev = "v${version}";
    hash = "sha256-igKaNZURyJE8MOrrrI4FpHBU7/ewB1RYtQVaSiiAG0A=";
  };

  build-system = [
    setuptools
    wheel
  ];

  propagatedBuildInputs = [
    pkgs.fuse
    pkgs.iconv
  ];

  nativeCheckInputs = [
    pytestCheckHook
    util-linux.mount
  ];

  # WONTFIX fuse: device not found, try 'modprobe fuse' first
  # https://discourse.nixos.org/t/using-fuse-inside-nix-derivation/8534
  doCheck = false;

  # On macOS, users are expected to install macFUSE. This means fusepy should
  # be able to find libfuse in /usr/local/lib.
  patchPhase = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    pwd
    ls
    substituteInPlace mfusepy.py \
      --replace \
        "find_library('fuse')" \
        "'${lib.getLib pkgs.fuse}/lib/libfuse.so'" \
      --replace \
        "find_library('iconv')" \
        "'${lib.getLib pkgs.iconv}/lib/libiconv.so'"
  '';

  pythonImportsCheck = [ "mfusepy" ];

  meta = {
    description = "Ctypes bindings for the high-level API in libfuse 2 and 3";
    homepage = "https://github.com/mxmlnkn/mfusepy";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ ];
  };
}
