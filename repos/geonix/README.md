![Build and populate cache](https://github.com/imincik/geonix/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-geonix-blue.svg)](https://geonix.cachix.org)

# Geospatial Packages for NIX

## Packages

Search for built packages: [Geonix NUR](https://nur.nix-community.org/repos/geonix/)


## Usage

### Install and configure Nix

* Install Nix on non-NixOS Linux (Ubuntu, Fedora, ...)
```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

* Enable new Nix command and Nix Flakes
```
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
```

* Add current user to Nix trusted users group
```
echo "trusted-users = $USER" | sudo tee -a /etc/nix/nix.conf
```

* Restart Nix daemon
```
sudo systemctl restart nix-daemon.service
```

_For Nix installation on Mac or Windows (WSL2) see
[Install Nix documentation](https://nix.dev/tutorials/install-nix#install-nix) ._

### Launch package

* Launch QGIS from Geonix GitHub repo
```
nix run github:imincik/geonix#qgis
```


## Development

* Build package (use `--check` to re-build already built package)
```
nix-build -A <PACKAGE>
```

* Run package passthru tests (use `--check` to re-run already succeeded tests)
```
nix-build -A <PACKAGE>.tests
```
