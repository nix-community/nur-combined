<!--
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
-->

# Greep's [NUR](https://github.com/nix-community/NUR) repository

![Fetch latest updates with nix-update](https://github.com/GreepTheSheep/nix-nurpkgs/actions/workflows/nix-update.yml/badge.svg)

![Build and populate cache](https://github.com/GreepTheSheep/nix-nurpkgs/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-greep-blue.svg?logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iNjQiIGhlaWdodD0iNjQiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PHBhdGggZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik00OS4wMzIgMjEuMzMyIDMyLjE0IDkuMzM0bC0xNy4xNzIgMTIuMDJ2MS42NTNsMTcuMTcyIDExLjc1TDQ5LjAzMiAyMy4wM3YtMS42OTdabS0zNy41MDQtMy42NzdBMy41OTcgMy41OTcgMCAwIDAgMTAgMjAuNjAzdjMuMTY1YzAgMS4xOS41ODQgMi4zMDIgMS41NTkgMi45NjhsMTguNTk3IDEyLjcyNmEzLjUxOCAzLjUxOCAwIDAgMCA0LS4wMTNsMTguMzA1LTEyLjcxQTMuNTk2IDMuNTk2IDAgMCAwIDU0IDIzLjc4MnYtMy4xOTZhMy41OTcgMy41OTcgMCAwIDAtMS41MDgtMi45MzNMMzQuMTg2IDQuNjUyYTMuNTE4IDMuNTE4IDAgMCAwLTQuMDYtLjAxNEwxMS41MjcgMTcuNjU1WiIgZmlsbD0iIzEwMTgyOCIvPjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNMTAuMDYzIDM0LjI0NWMuMTcxLjkzNS43MDYgMS43NzUgMS41IDIuMzE4TDMwLjE2MSA0OS4yOWEzLjUxOCAzLjUxOCAwIDAgMCA0LS4wMTRsMTguMzA1LTEyLjcxYTMuNTg5IDMuNTg5IDAgMCAwIDEuNDgzLTIuMzJoLTYuOTEzbC0xNC44OTEgMTAuMzQtMTUuMTEtMTAuMzRoLTYuOTcyWiIgZmlsbD0iIzEwMTgyOCIvPjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNMTAuMDYzIDQ0LjMzOWEzLjU5IDMuNTkgMCAwIDAgMS41IDIuMzE5bDE4LjU5OCAxMi43MjVhMy41MTggMy41MTggMCAwIDAgNC0uMDEzbDE4LjMwNS0xMi43MWEzLjU5IDMuNTkgMCAwIDAgMS40ODMtMi4zMjFoLTYuOTEzbC0xNC44OTEgMTAuMzQtMTUuMTEtMTAuMzRoLTYuOTcyWiIgZmlsbD0iIzEwMTgyOCIvPjwvc3ZnPg==)](https://greep.cachix.org)

## Packages

### Maintained by @GreepTheSheep

- [feishin](https://github.com/jeffvli/feishin): Full-featured Jellyfin, Navidrome, and OpenSubsonic Compatible Music Player
- [nxapi](https://github.com/samuelthomas2774/nxapi): Nintendo Switch Online/Parental Controls app APIs - CLI
- [nxapi-app](https://github.com/samuelthomas2774/nxapi): Nintendo Switch Online/Parental Controls app APIs - Electron app
- [tm-mumble-link](https://github.com/XertroV/tm-mumble-bridge): Bridge Trackmania's proximity-chat plugin to Mumble's Link plugin for positional audio

### Maintained by @bensuperpc

- [bs-thread-pool](https://github.com/bshoshany/thread-pool): BS::thread_pool: a fast, lightweight, modern, and easy-to-use C++17 / C++20 / C++23 thread pool library

## Development

Adding a package, updating versions, blacklisting a package from the automated updates: see [pkgs/README.md](./pkgs/README.md).
