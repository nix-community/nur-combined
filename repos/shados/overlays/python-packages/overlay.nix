self: super: with super.lib; {
  pythonOverrides = self.lib.buildPythonOverrides (pyself: pysuper: {
    # General language-specific support tools
    flake8-bugbear = pysuper.callPackage ./flake8-bugbear.nix { };
    flake8-per-file-ignores = pysuper.callPackage ./flake8-per-file-ignores.nix { };
  }) super.pythonOverrides;
}
