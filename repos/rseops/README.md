# rse-ops Nix packages

[![Build and populate cache](https://github.com/rse-ops/nix/actions/workflows/build.yaml/badge.svg)](https://github.com/rse-ops/nix/actions/workflows/build.yaml)
[![Cachix Cache](https://img.shields.io/badge/cachix-rseops-blue.svg)](https://rseops.cachix.org)

**A [NUR](https://github.com/nix-community/NUR) "Nix User Repository"**

You can see the repository under the [nur.nix-community.org](https://nur.nix-community.org/repos/rseops/).

## Usage

For local development, when you add a package:

```bash
$ nix-build -A <package-name>
```

Garbage collect:

```bash
$ nix-collect-garbage
```

Update flake.nix

```bash
$ nix flake update
# or 
$ nix flake lock --update-input nixpkgs
```

Add rseops from cachix

```bash
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use rseops
```

## Install Nix

If you outside the devcontainer and need to install nix:

```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. $HOME/.nix-profile/etc/profile.d/nix.sh
```

