{ lib, python3Packages, fetchFromGitHub }:

python3Packages.buildPythonApplication rec {
  pname = "lru-dict";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "amitdev";
    repo = "lru-dict";
    rev = "v${version}";
    hash = "sha256-+6E5vqjNjKXDfkx/rklsSIvP+JfsTtukCXp7NKxVUrY=";
  };

  checkInputs = with python3Packages; [ pytestCheckHook ];

  meta = with lib; {
    description = "A fast and memory efficient LRU cache for Python";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
  };
}
