{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  six,
  openpyxl,
  babel,
  packaging,
}:

buildPythonPackage (finalAttrs: {
  pname = "xlsx2html";
  version = "0.6.4";
  pyproject = true;

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-AQz2YPnADrAMxYtsen58M5TTov0Wllzf3aa5rQBOlH8=";
  };

  postPatch = ''
        # Expose a `main()` in xlsx2html/__main__.py so the console script entry
        # point below has a callable.
        substituteInPlace xlsx2html/__main__.py \
          --replace-fail 'if __name__ == "__main__":' 'def main():' \
          --replace-fail 'sys.exit()' 'return 1' \
          --replace-fail 'xlsx2html(sys.argv[1], sys.argv[2])' 'xlsx2html(sys.argv[1], sys.argv[2])
        return 0


    if __name__ == "__main__":
        sys.exit(main())'

        # Declare the `xlsx2html` console script.
        substituteInPlace setup.py \
          --replace-fail 'install_requires=["six", "openpyxl>=2.4.8", "babel>=2.3.4", "packaging>=20.4"],' 'install_requires=["six", "openpyxl>=2.4.8", "babel>=2.3.4", "packaging>=20.4"],
        entry_points={
            "console_scripts": [
                "xlsx2html = xlsx2html.__main__:main",
            ],
        },'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    six
    openpyxl
    babel
    packaging
  ];

  pythonImportsCheck = [
    "xlsx2html"
  ];

  meta = {
    description = "A simple export from xlsx format to html tables with keep cell formatting";
    homepage = "https://github.com/Apkawa/xlsx2html";
    license = lib.licenses.mit;
    mainProgram = "xlsx2html";
    maintainers = with lib.maintainers; [ nagy ];
  };
})
