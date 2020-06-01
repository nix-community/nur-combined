{ lib, newScope, pythonPackages }:
with lib;
let
  upstreamNewScope = scope: newScope (pythonPackages // scope);
  isPackageBroken = package: builtins.hasAttr "broken" package.meta && package.meta.broken;
  packages = (self: with self; {
    cognitive-complexity = callPackage ./cognitive-complexity {};
    darglint = callPackage ./darglint {};
    flake8-annotations-complexity = callPackage ./flake8-annotations-complexity {};
    flake8-bandit = callPackage ./flake8-bandit {};
    flake8-broken-line = callPackage ./flake8-broken-line/without-poetry.nix {};
    flake8-bugbear = callPackage ./flake8-bugbear {};
    flake8-builtins = callPackage ./flake8-builtins {};
    flake8-coding = callPackage ./flake8-coding {};
    flake8-commas = callPackage ./flake8-commas {};
    flake8-comprehensions = callPackage ./flake8-comprehensions {};
    flake8-docstrings = callPackage ./flake8-docstrings {};
    flake8-eradicate = callPackage ./flake8-eradicate {};
    flake8-executable = callPackage ./flake8-executable {};
    isort = callPackage ./isort { withPyproject = true; };
    flake8-isort = callPackage ./flake8-isort {};
    flake8-logging-format = callPackage ./flake8-logging-format {};
    flake8-pep3101 = callPackage ./flake8-pep3101 {};
    flake8-print = callPackage ./flake8-print {};
    flake8-quotes = callPackage ./flake8-quotes {};
    flake8-rst-docstrings = callPackage ./flake8-rst-docstrings {};
    flake8-string-format = callPackage ./flake8-string-format {};
    mando = callPackage ./mando {};
    pep8-naming = callPackage ./pep8-naming {};
    radon = callPackage ./radon {};
    wemake-python-styleguide = callPackage ./wemake-python-styleguide {};
    returns = callPackage ./returns/without-poetry.nix {};
    zope-hookable = callPackage ./zope-hookable {};
  });
in
  makeScope upstreamNewScope packages
