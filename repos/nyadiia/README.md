# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/nyadiia/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/nyadiia-nur?label=cachix&color=blue)](https://nyadiia-nur.cachix.org)

## package sources

uses [nvfetcher](https://github.com/berberman/nvfetcher) for automatic source updates. add packages to `nvfetcher.toml`, sources get generated to `_sources/generated.nix`, github actions creates PRs weekly when updates are available.