{
  lib,
  python3Packages,
  fetchFromGitHub,
}:
python3Packages.buildPythonPackage (finalAttrs: {
  pname = "termtables";
  version = "0.2.4";
  src = fetchFromGitHub {
    owner = "nschloe";
    repo = "termtables";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zSCWewHYe1kzY1hVU8+GbfQHXT0yY9MqTVpze9A/NKQ=";
  };

  pyproject = true;

  nativeBuildInputs = with python3Packages; [
    setuptools
  ];

  meta = {
    description = "Pretty tables in the terminal";
    homepage = "https://github.com/nschloe/termtables";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
