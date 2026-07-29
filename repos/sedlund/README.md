# nur-packages

Personal [NUR](https://github.com/nix-community/NUR) repository for `sedlund`.

![Build and populate cache](https://github.com/sedlund/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)
[![Cachix Cache](https://img.shields.io/badge/cachix-sedlund-blue.svg)](https://sedlund.cachix.org)

## Take a Peek

Take a peek at what I offer in store:

```bash
nix flake show github:sedlund/nur-packages
```

## Cachix

Add the `sedlund` Cachix cache declaratively:

```nix
nix.settings = {
  extra-substituters = [ "https://sedlund.cachix.org" ];
  extra-trusted-public-keys = [
    "sedlund.cachix.org-1:M7fyJk3z+yaJKCyI8U3fE7JH/v4yVYykmAVp6sXrB2o="
  ];
};
```

## Packages

| Package     | Description                                                 | URL                                   |
| ----------- | ----------------------------------------------------------- | ------------------------------------- |
| `deploy-rs` | `deploy-rs` fork packaged from `neunenak/deploy-rs`         | https://github.com/neunenak/deploy-rs |
| `ghoten`    | OpenTofu fork with ORAS backend and additional integrations | https://github.com/vmvarela/ghoten    |

## Automation

This repo ships two manual/scheduled update workflows:

- `Packages: update` updates all exported flake packages (from `packages.x86_64-linux`) using `nix-update`.
- `Flake.lock: update` updates both lock files in one run:
  - `flake.lock`
  - `dev/flake.lock`

Both workflows support `workflow_dispatch` from the GitHub Actions UI.

## Dev Inputs

Development-only flake inputs are partitioned under `dev/` using `flake-parts` partitions.

- Dev-only inputs: `treefmt-nix`, `git-hooks.nix`
- Consumer-facing package evaluation stays in the top-level flake output, so users of this flake do not need to pull in those dev inputs for normal package use.

## Lockfiles

When updating flake inputs locally:

```bash
nix flake update
nix flake update --flake ./dev
```
