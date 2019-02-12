# NUR packages

This repository contains a collection of packages for the [Nix package
manager](https://nixos.org/nix/). This collection is available from the
[Nix User Repository (NUR)](https://github.com/nix-community/NUR).

## Installation

First configure Nix to use NUR, following the instructions in [NUR
documentation](https://github.com/nix-community/NUR#installation).

Once Nix has been set up, you can use or install packages from this
repository with:

```
nix-shell -p nur.repos.smaret.astrochem
[nix-shell:~]$ astrochem
Usage: astrochem [option...] [file]

Options:
   -h, --help         Display this help
   -V, --version      Print program version
   -v, --verbose      Verbose mode
   -q, --quiet        Suppress all messages

See the astrochem(1) manual page for more information.
Report bugs to <http://github.com/smaret/astrochem/issues>.
```

or

```
nix-env -iA nur.repos.smaret.astrochem
```

[![Build Status](https://travis-ci.com/smaret/nur-packages.svg?branch=master)](https://travis-ci.com/smaret/nur-packages)


