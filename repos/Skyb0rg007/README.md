# Skyenet packages
Repo for all different packages

## NixOS

This subdirectory is a Nix flake.

Import with

```nix
{
    inputs.skyenet.url = "github:Skyb0rg007/packages.git?dir=NixOS";
    # If you're also depending on nixpkgs
    inputs.skyenet.inputs.nixpkgs.follows = "nixpkgs";
    # If you're also depending on cachix's git-hooks package
    inputs.skyenet.inputs.git-hooks.follows = "git-hooks";

    # ...
}
```

You can then the packages with `skyenet.packages.${system}.package-name`.
For `NixOS` or `home-manager` modules, you can pass extra arguments through
the `specialArgs` or `extraSpecialArgs` inputs respectively.

### Cachix substituter

Instead of building the packages on your machine, you can download
pre-built derivations courtesy of [Cachix](https://cachix.org).
Add the following to your `nix.conf`:

```conf
extra-substituters = https://skyenet.cachix.org
extra-trusted-public-keys = skyenet.cachix.org-1:Pf1Kzvduw4vFW0jGH3Vvaxkv8RYk2EK5LyPzhpYBI5s=
```

Note: the `extra-` prefix just means the line won't override previous configuration.

### Packages

See [NixOS/README.md](./NixOS/README.md).

## Ubuntu/Debian

I setup an APT repository hosted on GitHub Pages at https://apt.soss.website/.
The [README.html](https://apt.soss.website/README.html) has an installation
guide.

Note: I intentionally do not clone the source code in this repo.
To build, use the `build.sh` script which uses `uscan` to download the
sources from upstream.

### Packages

- `skyenet-archive-keyring`
  - [skyenet-archive-keyring/](./Debian/pkgs/skyenet-archive-keyring)
  - This package installs the gpg + apt sources files so that a user can
    install packages from the Skyenet repo through the `apt` command.
    Installing this is the entire "bootstrap" path.

- `golang-github-biezhi-gorm-paginator`
  - [golang-github-biezhi-gorm-paginator](./Debian/pkgs/golang-github-biezhi-gorm-paginator)
  - Dependency for pwngrid
  - GitHub: https://github.com/biezhi/gorm-paginator

### In-Progress

- `pwngrid`
  - GitHub: https://github.com/jayofelony/pwngrid

- `pwnagotchi`
  - GitHub: https://github.com/jayofelony/pwnagotchi

- `smlnj`
  - GitHub: https://github.com/smlnj/smlnj
