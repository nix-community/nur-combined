<div align="center">

# nurpkgs

_Personal [Nix User Repository](https://github.com/nix-community/NUR) with
packages, NixOS modules and overlays._

[![Nix Flake](https://img.shields.io/badge/Nix-flake-5277C3?style=for-the-badge&labelColor=081216&logo=nixos&logoColor=white)](flake.nix)
[![Binary cache](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Ffarbzen%2Fnurpkgs%2Factions%2Fworkflows%2Fbuild.yml%2Fruns%3Fbranch%3Dmain%26status%3Dsuccess%26exclude_pull_requests%3Dtrue%26per_page%3D1&query=%24.workflow_runs%5B0%5D.updated_at&label=cache&color=4C4A6A&style=for-the-badge&labelColor=081216)](https://app.cachix.org/cache/farbzen)
[![License: MIT](https://img.shields.io/badge/license-MIT-B0BFC9?style=for-the-badge&labelColor=081216)](LICENSE)
[![Ko-Fi donate](https://img.shields.io/badge/donate-kofi?style=for-the-badge&labelColor=081216&color=ee5556&logo=ko-fi&logoColor=white)](https://ko-fi.com/farbzen)

</div>

`nurpkgs` is my personal NUR repository. It bundles self-made Nix packages,
NixOS modules and overlays for NixOS users and exposes them both through the
classic NUR channel (`nur.repos.farbzen`) and as a Nix flake.

## Binary Cache

CI builds all packages and pushes them to the
[Cachix](https://www.cachix.org/) cache `farbzen`. Use it to skip local builds:

```sh
cachix use farbzen
```

### NixOS configuration

Add the cache declaratively to your `configuration.nix` or any NixOS module:

```nix
{
  nix.settings = {
    extra-substituters = ["https://farbzen.cachix.org"];
    extra-trusted-public-keys = ["farbzen.cachix.org-1:8KQga60LYPZVg0E4iKZgQhTmI5dV38Mb9iSuryp8BoY="];
  };
}
```

The `extra-*` options keep `cache.nixos.org` as the default substituter.

### Flakes

Declare the cache in the `nixConfig` of your own `flake.nix`:

```nix
{
  nixConfig = {
    extra-substituters = ["https://farbzen.cachix.org"];
    extra-trusted-public-keys = ["farbzen.cachix.org-1:8KQga60LYPZVg0E4iKZgQhTmI5dV38Mb9iSuryp8BoY="];
  };
}
```

Nix only applies `nixConfig` for trusted users and asks for confirmation
unless `accept-flake-config = true` is set. For system configurations, prefer
the NixOS module above.

> [!NOTE]
> CI builds via `default.nix` against the current heads of the
> `nixpkgs-unstable` and `nixos-unstable` channels and against the nixpkgs
> revision pinned in this flake's `flake.lock` (on every push to `main` and
> daily at 04:00 UTC). Store paths depend on the exact nixpkgs revision, so you
> only get cache hits if the nixpkgs your packages are built with matches a
> revision CI has built:
>
> - **NUR / channels**: hits are likely while your `nixos-unstable` or
>   `nixpkgs-unstable` channel is up to date.
> - **Flake with `inputs.nurpkgs.inputs.nixpkgs.follows = "nixpkgs"`**: hits
>   require your own `nixpkgs` input to track one of these channels and to be
>   updated regularly.
> - **Flake without `follows`**: packages use the nixpkgs pinned in this
>   repository's `flake.lock`, so hits are likely for every commit CI has built
>   on `main`.

## License

See [LICENSE](LICENSE).
