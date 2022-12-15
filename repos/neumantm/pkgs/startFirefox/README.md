# Start Firefox

A small wrapper script to start a specific profile of firefox

## Usage

Specify the available profiles as `firefoxProfiles`.

When it is installed just run `startFirefox` and you will be prompted.
A Firefox desktop entry is also created.

The path to the special TMP profile should also be specified to allow for it to be deleted.

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
    startFirefox = (with pkgs; nur.repos.neumantm.startFirefox.override {
      firefoxProfiles = [ "Default" "Movies" "Banking" ];
      firefoxTmpProfileDIr = "/home/name/.mozilla/firefox/dm452oi3.TMP/";
    });
  };
  environment.systemPackages = with pkgs; [
    startFirefox
  ];
}
```
