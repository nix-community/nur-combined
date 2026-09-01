{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  rich-click,
}:


buildPythonPackage (finalAttrs: {
  pname = "android-unpinner";
  version = "202107.1047";

  src = fetchFromGitHub {
    owner = "mitmproxy";
    repo = "android-unpinner";
    rev = "f5ced37a9e40740d160faef9491121ba2df48ffe";
    hash = "sha256-ZGUj5d47rEovpz7Wz25670OPaxT1mA2st7+L6Nz1G3w=";
  };

  doCheck = false;

  postPatch = ''
    substituteInPlace \
      android_unpinner/__init__.py \
      --replace-fail '__version__ = "1.0"' '__version__ = "${finalAttrs.version}"'
  '';

  dependencies = [
    rich-click
  ];

  pyproject = true;
  build-system = [
    setuptools
  ];

  meta = {
    description = "Remove Certificate Pinning from APKs";
    homepage = "https://github.com/mitmproxy/android-unpinner";
    changelog = "https://github.com/mitmproxy/android-unpinner/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
    mainProgram = "android-unpinner";
  };
})
