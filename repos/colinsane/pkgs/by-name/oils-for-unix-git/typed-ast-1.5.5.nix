{
  lib,
  fetchFromGitHub,
  python3,
}:

# typed-ast was removed from nixpkgs but is needed for mypy 0.780
python3.pkgs.buildPythonPackage (finalAttrs: {
  pname = "typed-ast";
  version = "1.5.5";
  pyproject = true;
  build-system = [ python3.pkgs.setuptools ];

  src = fetchFromGitHub {
    owner = "python";
    repo = "typed_ast";
    rev = finalAttrs.version;
    hash = "sha256-A/FA6ngu8/bbpKW9coJ7unm9GQezGuDhgBWjOhAxm2o=";
  };

  # GCC 15 uses C23 by default where false/true/bool are keywords
  # Force C11 to build this legacy package
  env.NIX_CFLAGS_COMPILE = "-std=c11";

  pythonImportsCheck = [ "typed_ast" ];
  meta.license = lib.licenses.asl20;
})
