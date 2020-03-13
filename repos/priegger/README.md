# nur-packages
[![builds.sr.ht status](https://builds.sr.ht/~priegger/nur-packages/stable.yml.svg)](https://builds.sr.ht/~priegger/nur-packages/stable.yml?)

My personal nix repository

## Usage

To make the repository accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:

    {
      packageOverrides = pkgs: {
        priegger = pkgs.callPackage (import (builtins.fetchGit {
          url = "https://git.sr.ht/~priegger/nur-packages";
        })) {};
      };
    }

Then packages can be used or installed from the `priegger` namespace.

    $ nix-shell -p priegger.nanoc

or

    $ nix-env -iA nixos.priegger.nanoc

For NixOS add the following to your `/etc/nixos/configuration.nix`:

    {
      nixpkgs.config.packageOverrides = pkgs: {
        priegger = pkgs.callPackage (import (builtins.fetchGit {
           url = "https://git.sr.ht/~priegger/nur-packages";
        })) {};
      };

      # Packages can be installed from the "priegger" namespace.
      environment.systemPackages = [
        pkgs.priegger.nanoc
      ];
    }

## Development

Run tests using

	nix-build tests/reresolve-dns.nix
