# apply nixpkgs#302139
final: prev: {
  omniorb = final.callPackage ../pkgs/omniorb { };
  omniorbpy = final.python3Packages.callPackage ../pkgs/omniorbpy { };
  pythonPackagesOverlays = [
    (python-final: _: {
      omniorb = python-final.callPackage ../pkgs/omniorb { };
      omniorbpy = python-final.callPackage ../pkgs/omniorbpy { };
    })
  ];
}
