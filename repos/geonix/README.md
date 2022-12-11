![Build and populate cache](https://github.com/imincik/geonix/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-geonix-blue.svg)](https://geonix.cachix.org)

# Geospatial Packages for NIX

## Packages

Search for built packages: [Geonix NUR](https://nur.nix-community.org/repos/geonix/)


## Usage

### Launch package

* Launch QGIS from GitHub
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
