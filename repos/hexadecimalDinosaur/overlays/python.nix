final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (import ../python.nix)
  ];
}
