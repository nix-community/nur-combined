![Build and populate cache](https://github.com/imincik/geonix/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-geonix-blue.svg)](https://geonix.cachix.org)

# Geospatial Packages for NIX

## Packages

Search for built packages: [Geonix NUR](https://nur.nix-community.org/repos/geonix/)


## Development

* Build package
```
nix-build --check -A <PACKAGE>
```

* Run package passthru tests
```
nix-build --check -A <PACKAGE>.tests
```
