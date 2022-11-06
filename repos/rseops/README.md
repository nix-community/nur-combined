# rse-ops Nix packages

**A [NUR](https://github.com/nix-community/NUR) "Nix User Repository"**

## Usage

For local development, when you add a package:

```bash
$ nix-build -A <package-name>
```

## Additional Setup Still Needed

1. Add back .github/workflows to test packages: Change your NUR repo name and optionally add a cachix name in [.github/workflows/build.yml](./.github/workflows/build.yml) and change the cron timer (TBA)


<!-- Remove this if you don't use github actions
![Build and populate cache](https://github.com/<YOUR-GITHUB-USER>/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)-->

