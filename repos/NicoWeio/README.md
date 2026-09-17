# NUR packages

Personal [Nix User Repository (NUR)](https://github.com/nix-community/NUR)
packages.

## Packages

| Package | Description |
| --- | --- |
| `radiopropa` | Radio propagation in inhomogeneous media ray tracing. |
| `rainlendar2` | Customizable desktop calendar (Rainlendar Lite). |

## Installation

Once this repository is registered in NUR, install a package through the NUR
namespace:

```nix
environment.systemPackages = [
	pkgs.nur.repos.NicoWeio.rainlendar2
];
```

`rainlendar2` is unfree, so the Nixpkgs configuration must allow unfree
packages:

```nix
nixpkgs.config.allowUnfree = true;
```

To run Rainlendar directly without installing it:

```sh
nix run github:NicoWeio/nur-packages#rainlendar2
```

## Development

Build all packages exported by the top-level `default.nix`:

```sh
for attribute in $(nix-env -f . -qaP --arg pkgs 'import <nixpkgs> { config.allowUnfree = true; }' --json | jq -r 'keys[]'); do
	nix-build --no-out-link -A "$attribute" --arg pkgs 'import <nixpkgs> { config.allowUnfree = true; }'
done
```

The GitHub Actions workflow performs the same evaluation and sequential build on
every push and pull request.

### CI binary cache

CI uses [Cachix](https://cachix.org) to restore and publish Nix store paths.
Create the Cachix cache, then configure these GitHub repository settings:

- Variable `CACHIX_CACHE_NAME`: the name of the Cachix cache.
- Secret `CACHIX_AUTH_TOKEN`: a per-cache token with write access.

Pull requests from forks do not receive the secret, so they can only restore
from a public cache and do not publish build outputs.
