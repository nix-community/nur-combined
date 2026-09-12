{
  buildPythonPackage,
  setuptools,
  tree-sitter,
  fetchFromGitHub,
}:

buildPythonPackage rec {
  pname = "tree-sitter-devicetree";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "joelspadin";
    repo = "tree-sitter-devicetree";
    rev = "v${version}";
    hash = "sha256-iMmr4zSm6B7goevHE03DMj9scW4ldXS7CV74sKeqGD4=";
  };
  pyproject = true;

  buildInputs = [ tree-sitter ];

  build-system = [ setuptools ];
}
