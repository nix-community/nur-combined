# nixpkgs

Set of expressions to run [`angr`](https://angr.io) on Nix/NixOS.

[![Build Status](https://travis-ci.com/angr/nixpkgs.svg?branch=master)](https://travis-ci.com/angr/nixpkgs)


## Installation

### Via NUR

This repository has been made part of the Nix User Repository ([see details, documentation, and installation guide](https://github.com/nix-community/NUR#nur)).

With NUR set-up, `angr` can be made available to a `nix-shell` with the following:

```
nix-shell -p 'python3.withPackages(ps: with ps; [ nur.repos.angr.python3Packages.angr ])'
```

### Standalone

```
git clone git@github.com:angr/nixpkgs.git angr-nixpkgs
export ANGR_NIXPKGS="$(pwd)"
nix-shell --arg ANGR_NIXPKGS_PATH "$ANGR_NIXPKGS"
```

  * For a more "persistent" solution, add `export ANGR_NIXPKGS="$(pwd)/angr-nixpkgs"` to your shell configuration file.
  * To stay up-to-date, you will have to fetch and rebase your local repository manually.

## Contribute

> In all this, please keep in mind that angr is a large project being frantically worked on by a very small group of overworked students. It's open source, with a typical open source support model (i.e., pray for the best).
<sup id="a1">[1](#f1)</sup>

That being said, you are more than welcome to open [issues](https://github.com/angr/nixpkgs/issues), and even submit [pull requests](https://github.com/angr/nixpkgs/compare); Feedback appreciated!

---

<b id="f1">1</b> Source: <a href='https://angr.io' target='blank'>https://angr.io</a> . [↩](#a1)
