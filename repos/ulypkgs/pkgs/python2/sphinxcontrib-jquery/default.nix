{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  fetchpatch,
  flit-core,
  defusedxml,
  pytestCheckHook,
  sphinx,
  python,
}:

buildPythonPackage rec {
  pname = "sphinxcontrib-jquery";
  version = "4.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "sphinx-contrib";
    repo = "jquery";
    tag = "v${version}";
    hash = "sha256-ZQGQcVmhWREFa2KyaOKdTz5W2AS2ur7pFp8qZ2IkxSE=";
  };

  patches = [
    ./fix-toml.patch
  ];

  nativeBuildInputs = [ flit-core ];

  pythonImportsCheck = [ "sphinxcontrib.jquery" ];

  dependencies = [
    sphinx
  ];

  nativeCheckInputs = [
    #defusedxml
    #pytestCheckHook # disable pytest check because test uses python 3 syntax
  ];

  pythonNamespaces = [ "sphinxcontrib" ];

  preFixup = ''
    rm $out/${python.sitePackages}/sphinxcontrib/__init__.py
  '';

  meta = {
    description = "Extension to include jQuery on newer Sphinx releases";
    longDescription = ''
      A sphinx extension that ensures that jQuery is installed for use
      in Sphinx themes or extensions
    '';
    homepage = "https://github.com/sphinx-contrib/jquery";
    changelog = "https://github.com/sphinx-contrib/jquery/blob/v${version}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ kaction ];
  };
}
