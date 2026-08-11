{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitHub,
  pkgs,

  # build-system
  setuptools,
  pytestCheckHook,

  # tests
  tree-sitter-python,
  tree-sitter-rust,
  tree-sitter-html,
  tree-sitter-javascript,
  tree-sitter-json,
}:

buildPythonPackage rec {
  pname = "tree-sitter";
  version = "0.25.1-89a7e2a";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tree-sitter";
    repo = "py-tree-sitter";
    # https://github.com/tree-sitter/py-tree-sitter/pull/415
    rev = "89a7e2a7eb744d722ace681fe24ba94fd0176c75";
    hash = "sha256-DyZJDY7ozyw7GPbO5Bl62wPcERiB06FtiwY17DeEYQU=";
    fetchSubmodules = true;
  };

  # see https://github.com/tree-sitter/py-tree-sitter/issues/330#issuecomment-2629403946
  patches = lib.optionals (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isLinux) [
    ./segfault-patch.diff
  ];

  build-system = [ setuptools ];

  buildInputs = [
    pkgs.tree-sitter
  ];

  nativeCheckInputs = [
    pytestCheckHook
    tree-sitter-python
    tree-sitter-rust
    tree-sitter-html
    tree-sitter-javascript
    tree-sitter-json
  ];

  pythonImportsCheck = [ "tree_sitter" ];

  preCheck = ''
    # https://github.com/NixOS/nixpkgs/issues/255262#issuecomment-1721265871
    rm -r tree_sitter
  '';

  disabledTests = [
    # test fails in nix sandbox
    "test_dot_graphs"
  ];

  meta = {
    description = "Python bindings to the Tree-sitter parsing library";
    homepage = "https://github.com/tree-sitter/py-tree-sitter";
    changelog = "https://github.com/tree-sitter/py-tree-sitter/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
