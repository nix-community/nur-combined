{ mySources
, python3
, lib
, pacman
  # , setuptools-generate
}:

with python3.pkgs;

buildPythonPackage rec {
  inherit (mySources.pkgbuild-language-server) pname version src;
  format = "pyproject";
  disabled = pythonOlder "3.6";
  propagatedBuildInputs = [
    pygls
    platformdirs
    pypandoc
    markdown-it-py
    pacman
    # pyalpm
  ];
  # nativeCheckInputs = [
  #   setuptools-generate
  # ];
  pythonImportsCheck = [
    "pkgbuild_language_server"
  ];

  meta = with lib; {
    homepage = "https://pkgbuild-language-server.readthedocs.io";
    description = "PKGBUILD language server";
    license = licenses.gpl3;
    maintainers = with maintainers; [ Freed-Wu ];
    platforms = platforms.unix;
  };
}
