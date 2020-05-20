# Multi Eclipse

A executable called eclipse which allows you to choose between multiple eclipse packages.

## Usage

Specify the available eclipse packages as `myEclipsePackages`.

When it is installed just run `eclipse` and you will be prompted.

Example:
```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    myEclipse = (with pkgs; nur.repos.neumantm.multiEclipse.override { myEclipsePackages = with eclipses; [eclipse-sdk eclipse-modeling]; });
  };
  environment.systemPackages = with pkgs; [
    myEclipse
  ];
}
```

You can also specify the log file for any stdout and stderr by setting `logFile`.
