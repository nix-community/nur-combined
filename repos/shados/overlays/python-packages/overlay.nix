self: super: with super.lib; {
  pythonOverrides = self.lib.buildPythonOverrides (pyself: pysuper: {
    icmplib = pyself.callPackage ./icmplib.nix { };
    # General language-specific support tools
    flake8-bugbear = pyself.callPackage ./flake8-bugbear.nix { };
    flake8-per-file-ignores = pyself.callPackage ./flake8-per-file-ignores.nix { };
  }) super.pythonOverrides;
}
