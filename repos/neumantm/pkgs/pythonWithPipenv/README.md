# Python With Pipenv

A wrapper for python with a working pipenv and support for wheels (binary distribution of native libraries) with manylinux.

## Usage
For the default functionality just install this package as any other NUR package.

To override the used python derivation override the argument `myPythonDerivation`. The default is the derivation named `python`. \
To add python packages to be installed override the argument `myPythonPackages`.

Example:
```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  environment.systemPackages = with pkgs; [
   #nur.repos.neumantm.pythonWithPipenv #For default functionality
    nur.repos.neumantm.pythonWithPipenv.override { myPythonDerivation = python37; myPythonPackages = pp: with pp; [ pylint ]; }
  ];
}
```

## Acknowledgements
This derivation is based on a [blogpost](https://sid-kap.github.io/index.html) by Sidharth (Sid) Kapur.
Thanks to haslersn for help with putting it together.

