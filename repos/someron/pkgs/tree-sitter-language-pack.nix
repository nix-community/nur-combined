{
  python3,
}:
let
  python = python3;
  pname = "tree-sitter-language-pack";
  version = "v1.8.1";
  sha256 = "sha256:0q5dlh3ld1pf9jcdj0jxx8jvqy2q2ffvfl0lnws3vjy16mwdy193";
in
python.pkgs.buildPythonPackage {
  inherit pname version;
  format = "wheel";
  src = builtins.fetchurl {
    url = "https://files.pythonhosted.org/packages/fa/a4/629e6983a93fbb52dc50af495ec0431565c6477eea4680d4298238e9831e/tree_sitter_language_pack-1.6.2-cp310-abi3-manylinux_2_34_x86_64.whl";
    inherit sha256;
  };
}