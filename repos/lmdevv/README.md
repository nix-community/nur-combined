# nur-packages-template

**A template for [NUR](https://github.com/nix-community/NUR) repositories**

## Setup

1. Click on
   [Use this template](https://github.com/nix-community/nur-packages-template/generate)
   to start a repo based on this template. (Do _not_ fork it.)
2. Add your packages to the [pkgs](./pkgs) directory and to
   [default.nix](./default.nix)
   - Remember to mark the broken packages as `broken = true;` in the `meta`
     attribute, or travis (and consequently caching) will fail!
   - Library functions, modules and overlays go in the respective directories
3. Choose your CI: Depending on your preference you can use github actions
   (recommended) or [Travis ci](https://travis-ci.com).
   - Github actions: Change your NUR repo name and optionally add a cachix name
     in [.github/workflows/build.yml](./.github/workflows/build.yml) and change
     the cron timer to a random value as described in the file
   - Travis ci: Change your NUR repo name and optionally your cachix repo name
     in [.travis.yml](./.travis.yml). Than enable travis in your repo. You can
     add a cron job in the repository settings on travis to keep your cachix
     cache fresh
4. Change your travis and cachix names on the README template section and delete
   the rest
5. [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository)

## README template

# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->

![Build and populate cache](https://github.com/lmdevv/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)

## Packages

### cursor-agent (unfree)

The `cursor-agent` CLI is distributed as a prebuilt binary bundle by Cursor
(license: unfree). This package mirrors the upstream tarball and installs a
`cursor-agent` executable.
