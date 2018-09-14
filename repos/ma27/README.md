# nur-packages

My own nix expressions distributed with [nix-community/NUR](https://github.com/nix-community/nur).

## Setup

Add `NUR` as [described in the docs](https://github.com/nix-community/nur#how-to-use):

``` nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

## Packages

* `gianas-return` (`pkgs.nur.repos.ma27.gianas-return`): Giana’s Return aims to be a worthy
  UNOFFICIAL sequel of 'The Great Giana Sisters'.

## Overlays

There are several overlays available that can be imported with an expression like this:

``` nix
{ pkgs, config, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    pkgs = import <nixpkgs> {}; # create dummy pkgs to load modules (that require `pkgs.lib` for evaluation)
  };
in
  {
    nixpkgs.overlays = [
      nur-no-pkgs.repos.ma27.overlays.<overlay-name>
    ];
  }
```

The following overlays are available:

* `overlays.sudo`: Provides a patched `sudo` with the `--with-insults` flag enabled.
* `overlays.termite`: Provides a patched `termite` with the patch
  from [`thestinger/termite#621`](https://github.com/thestinger/termite/pull/621) which allows to
  use `termite` without the `F11` hotkey enabled. This is e.g. helpful when using `weechat` in `termite`.
* `overlays.hydra`: `hydra` package with a patch that disables restricted jobset evaluation. This can be
  helpful in to evaluate jobsets that require e.g. Git checkouts.

## Modules

### Initial setup

Modules can be loaded by importing a second `nur` repo as described
[in the upstream docs](https://github.com/nix-community/NUR#using-modules-overlays-or-library-functions-in-nixos):

``` nix
{ pkgs, config, ... }:

let
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    pkgs = import <nixpkgs> {}; # create dummy pkgs to load modules (that require `pkgs.lib` for evaluation)
  };
in
{
  imports = with nur-no-pkgs.repos.ma27.modules; [
    hydra
  ];
}
```

### Hydra setup

The [Hydra CI](https://nixos.org/hydra/) is a build system for Nix.

This `hydra` module enhances `services.hydra` with several features such as an automated
configuration and a VHost setup. Furthermore it provides (optionally) a patch which creates
a Hydra instance with disabled eval restrictions using the `overlays.hydra` overlay from this NUR repository.

A basic configuration for a fully automated Hydra instance may look like this:

``` nix
{
  ma27.hydra = {
    enable = true;
    architectures = [ "x86_64-linux" ];       # which architectures shall be supported
    vhost = "hydra.example.org";              # VHost to listen on
    email = "random@email.org";               # admin email (e.g. for ACME cert)
    initialPassword = "randompwd";            # initial password for the admin account
    keyDir = "hydra.random.org";              # keydir for the build artifacts (also used for the binary cache name), lives in `/etc/nix/${keyDir}`
    extraConfig = {                           # basic extra config for `services.hydra` from nixpkgs
      # …
    };
  };
}
```

**Limitations**:

* Only allows local build machines (currently `x86_64-linux` only).
* Fairly opinionated, lacks several features.

For private repositories a private key has to be generated to allow
Hydra to clone them:

```
sudo -u hydra -i
ssh-keygen
```

In order to clone a `git` repository, the previously generated pubkey for Hydra
needs to be uploaded to the given `git` upstream server.

## Additional library

This repository ships several simple helper APIs to simplify Nix-based development
on a daily basis.

### Tex Environment

The library shipped with this `NUR` package contains a minimalistic API to develop and build
[LaTeX documents](https://www.latex-project.org//) using [texlive](https://www.tug.org/texlive/).

A simple environment may look like this:

``` nix
with import <nixpkgs> {};

let

  # create dummy pkgs to load modules (that require `pkgs.lib` for evaluation)
  nur-no-pkgs = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    pkgs = import <nixpkgs> {};
  };

  inherit (nur-no-pkgs.repos.ma27.lib) mkTexDerivation;

in

mkTexDerivation {
  name = "name-of-the-document";
  src = ./.;
  buildInputs = [ /* (optional) aditional build inputs */ ];

  /*
    Components shipped inside the `texlive` metapackage.

    By default the components `scheme-basic` and `scheme-small`
    are provided. If no further components are needed, this property can be omitted.
  */
  texComponents = [
    "beamer"
  ];
}
```

To build the documents in `$src` it's sufficient to run `nix-build`. After that the rendered PDFs will be
available at `$out/docs`.

The shell environment using `nix-shell` can be used to develop and build `.tex`
documents and contains a simple `texlive` environment, the packages`zathura`
and `pdfpc` to develop, view and present documents.

The shell script `watch-tex` allows to watch `.tex` and `.bib` files and rebuilds them on every
file change which is detected by `md5sum`. The script can be used inside `nix-shell` like this:

```
$ nix-shell
[nix-shell:~]$ watch-tex book.tex # rebuilds `book.tex' for each change
[nix-shell:~]$ watch-tex book.tex literature.bib # builds book.tex and literatur.bib on every change
```

### Hydra build library

The package expressions in this repository are tested using Hydra CI. To simplify such builds,
the `release` library can be used.

It basically consists of two functions:

* `checkoutNixpkgs`: Loads `nixpkgs` from a given channel and allows to modify the package set using overlays.
  An exemplary usage may look like this:

  ``` nix
  checkoutNixpkgs {
    channel = "18.09";
    overlays = [
      (self: super: {
        # …
      })
    ];
  }
  ```

  It returns an attribute set with the values `packageSet` and `nixpkgsArgs`. Several APIs
  such as `release-lib.nix` require a split of these two values.

  To simply create a `nixpkgs` checkout from a given channel, the following expression an be used:

  ```
  (checkoutNixpkgs { channel = "unstable"; }).invoke { /* overrides to the nixos package set */ }
  ```

* `mkJob`: helper function which acts as shortcut to easily generate jobset attribute sets.

  A job declaration may look like this:

  ```

  mkJob {
    channel = "18.09";                    # channel to use for the job
    overlays = [];                        # additional overlays to be used inside the jobset
    supportedSystem = "x86_64-linux";     # determine which environments are support for the build.
    jobset = pkgs: { mapTestOn, linux, …  }:
      mapTestOn {
        any-pkg = linux;
        another-pkg = linux;
      };
  }
  ```

  The jobset function alows expressions based on the previous `nixpkgs` and an attribute set for
  security and observation concerns.
