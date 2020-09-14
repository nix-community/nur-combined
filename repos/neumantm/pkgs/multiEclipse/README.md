# Multi Eclipse

A executable called eclipse which allows you to choose between multiple eclipse packages.

## Usage

Specify the available eclipse packages as `myEclipsePackages`.

When it is installed just run `eclipse` and you will be prompted.
An eclipse desktop entry is also created.

Additional JREs to be installed can be configured with `additionalJREs`. 
This should be a list of packages.
The script will print a list of the base paths of these JREs.
In most cases some additional path segments are required for configuring in eclipse.
For current openjdk packages `/lib/openjdk` must be appended.

Example:
```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    myEclipse = (with pkgs; nur.repos.neumantm.multiEclipse.override { 
      myEclipsePackages = with eclipses; [eclipse-sdk eclipse-modeling]; 
      additionalJREs = [ jdk11, jdk14 ];
    });
  };
  environment.systemPackages = with pkgs; [
    myEclipse
  ];
}
```

You can also specify the log file for any stdout and stderr by setting `logFile`.
