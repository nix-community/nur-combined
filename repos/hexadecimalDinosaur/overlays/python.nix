final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    ((import ../python.nix { lib = final.lib; }) null)
  ];
}
