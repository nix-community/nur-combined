# nur-packages-template

**A template for [NUR](https://github.com/nix-community/NUR) repositories**

## Setup

- [x] Click on [Use this template](https://github.com/nix-community/nur-packages-template/generate) to start a repo based on this template. (Do _not_ fork it.)
- [x] Add your packages to the [pkgs](./pkgs) directory and to
   [default.nix](./default.nix)
   - [x] Remember to mark the broken packages as `broken = true;` in the `meta`
     attribute, or travis (and consequently caching) will fail!
   - [x] Library functions, modules and overlays go in the respective directories
- [x] Choose your CI: Depending on your preference you can use github actions (recommended) or [Travis ci](https://travis-ci.com).
   - [x] Github actions: Change your NUR repo name and optionally add a cachix name in [.github/workflows/build.yml](./.github/workflows/build.yml) and change the cron timer
     to a random value as described in the file
- [x] Change your travis and cachix names on the README template section and delete
   the rest
- [ ] [Add yourself to NUR](https://github.com/nix-community/NUR#how-to-add-your-own-repository)

## README template

# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/edejong/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
