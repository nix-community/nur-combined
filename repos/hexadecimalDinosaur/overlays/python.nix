final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    ((import ../python.nix { pkgs = final; lib = final.lib; }) null)
  ];
}
