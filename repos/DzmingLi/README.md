# nur-packages-template

**A template for [NUR](https://github.com/nix-community/NUR) repositories**

## Setup

1. Click on [Use this template](https://github.com/nix-community/nur-packages-template/generate) to start a repo based on this template. (Do _not_ fork it.)
2. Add your packages to the [pkgs](./pkgs) directory and to
   [default.nix](./default.nix)
   * Remember to mark the broken packages as `broken = true;` in the `meta`
     attribute, or travis (and consequently caching) will fail!
   * Library functions, modules and overlays go in the respective directories
3. Choose your CI: Depending on your preference you can use github actions (recommended) or [Travis ci](https://travis-ci.com).
   - Github actions: Change your NUR repo name and optionally add a cachix name in [.github/workflows/build.yml](./.github/workflows/build.yml) and change the cron timer
     to a random value as described in the file
   - Travis ci: Change your NUR repo name and optionally your cachix repo name in 
   [.travis.yml](./.travis.yml). Than enable travis in your repo. You can add a cron job in the repository settings on travis to keep your cachix cache fresh
5. Change your travis and cachix names on the README template section and delete
   the rest
6. [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository)

## README template

# nur-packages

Package maintenance uses the standard `passthru.updateScript` interface. From
a clean checkout on x86_64 Linux:

```sh
nix run .#update -- --list
nix run .#update -- 115life -- --check
nix run .#update -- wechat
nix run .#update -- --all --commit
nix build .#checks.x86_64-linux.update-transactions
```

Each package declares its command and tool dependencies. Keep custom scripts
beside the package as `update.nu` (or another appropriate language); use
`nix-update-script` for supported upstreams. Do not commit from an update script.
The runner realizes the selected script's dependencies, passes the standard
`UPDATE_NIX_*` environment variables, and builds changed packages, including
unfree packages. It restores failed updates, continues with other packages,
and returns a failure status if any update failed. Without `--commit`, successful
updates remain as working-tree changes. CI commits and pushes successful updates
and reports failures. Packages with an `updateScript` are discovered automatically;
there is no second package list in CI. Update scripts must restrict changes to
their own `pkgs/<attribute>/` directory.

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/<YOUR-GITHUB-USER>/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-<YOUR_CACHIX_CACHE_NAME>-blue.svg)](https://<YOUR_CACHIX_CACHE_NAME>.cachix.org)
