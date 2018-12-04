# nixexprs

This repository contains opinionated Nix expressions and my personal
Hydra jobsets.

Most of the code isn't suitable for the NixOS upstream as it isn't sufficiently
stable and mostly subject to change. However feedback and further ideas
are always welcome.

## Obtain the sources

* The repo is part of the [NUR](https://github.com/nix-community/NUR) repository,
  a collection of user-contributed Nix expressions and can be installed as part of it:

  ``` nix
  {
    nixpkgs.overlays = [
      (_: super: {
        nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          pkgs = super;
        };
      })
    ];

    environment.systemPackages = [ pkgs.nur.repos.ma27.gianas-return ];
  }
  ```

* It's also possible to add an entry to your `$NIX_PATH` to retrieve components inside your Nix expressions:

  ``` nix
  { pkgs, ... }:
  let
    nixexprs = pkgs.fetchFromGitLab {
      owner = "Ma27";
      repo = "nixexprs";
      rev = "a98e9c8fe53fd4f9f893e04de1c3b76b9e900508";
      sha256 = "1s6qcr8wa05pxljfbbdd8pl6h36f5hx6k98nzmzyg4n1192y33mb";
    };
  in
    {
      nix.nixPath = [
        "nixexprs=${nixexprs}"
      ];
    }
  ```

  Now it can be referred to it like this:

  ``` nix
  with import <nixpkgs> { };
  with import <nixexprs> { inherit pkgs; };

  gianas-return
  ```

  By default this repo only components that don't depend on `nixpkgs`. This is helpful if only
  overlays and modules are needed to save evaluation time. If library functions (that rely on `nixpkgs/lib`)
  or packages are used, `pkgs` needs to be specified explicitly.

* Additionally it's possible to simply clone the repository and
  import its components:

  ```
  git clone git@gitlab.com:Ma27/nixexprs
  ```

  ``` nix
  {
    nixpkgs.overlays = builtins.attrValues (import ../nixexprs { }).overlays;
  }
  ```

* A Hydra jobset for the repository can be
  fonud at [hydra.mbosch.me/](https://hydra.mbosch.me/jobset/infra/nur), but it's mainly
  intended to track the status of all components in this repository and less
  to actually use it as binary cache.

## Packages

* `gianas-return` (`pkgs.nur.repos.ma27.gianas-return`): Giana’s Return aims to be a worthy
  UNOFFICIAL sequel of 'The Great Giana Sisters'.

## Overlays

There are several overlays available that can be imported with an expression like this:

``` nix
let
  overlays = (import <nixexprs> { }).overlays;
in
  import <nixpkgs> { overlays = [ overlays.sudo ]; };
```

The following overlays are available:

* `overlays.sudo`: Provides a patched `sudo` with the `--with-insults` flag enabled.

* `overlays.termite`: Provides a patched `termite` with the patch
  from [`thestinger/termite#621`](https://github.com/thestinger/termite/pull/621) which allows to
  use `termite` without the `F11` hotkey enabled. This is e.g. helpful when using `weechat` in `termite`.

* `overlays.hydra`: `hydra` package with a patch that disables restricted jobset evaluation. This can be
  helpful in to evaluate jobsets that require e.g. Git checkouts.

* `overlays.php`: Builds a PHP with `xsl` and `apcu` support enabled by default (please not that `xsl`
  needs a full ebuild of PHP).

## Modules

It's **not** recommended to import modules when using this repo via NUR, instead this can be done
like this:

``` nix
{ pkgs, config, ... }:

let
  modules = (import <nixexprs> { }).modules;
in
  {
    imports = [ modules.hydra ];
  }
```

### `ma27.sieve-dsl`

This is a simple module to allow sieve scripting for `dovecot2` instances. [Sieve](http://sieve.info/)
is a filtering DSL to declaratively specify which mail should land in which inbox.

A simple example may look like this:

``` nix
{
  # this is a very basic and incomplete dovecot2 configuration.
  # for a full-blown setup use something like `simple-nixos-mailserver`, please.
  services.dovecot2.enable = true;

  ma27.sieve-dsl.enable = true;
  ma27.sieve-dsl.rules = {
    "*github.com".fileinto = "Notifications";
  };
}
```

This is configuration would filter all incoming mail from `@github.com` and place it into the
`Notifications` inbox.

In case of mailing lists where the recipient is the address itself you can specify something like this:

``` nix
{
  # ...

  ma27.sieve-dsl.rules."your-mailing-list.example.com" = {
    fileinto = "Conversations";
    parts = [ "from" ];
  };
}
```

### `ma27.hydra`

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

## Library

This repository ships several simple helper APIs to simplify Nix-based development
on a daily basis.

### Tex Environment

The library shipped with this `NUR` package contains a minimalistic API to develop and build
[LaTeX documents](https://www.latex-project.org//) using [texlive](https://www.tug.org/texlive/).

A simple environment may look like this:

``` nix
with import <nixpkgs> { };
with import <nixexprs> { inherit pkgs; };

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

### Helper functions

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

  ``` nix
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

* `callNURPackage`: Basically `callPackage`, but has all items from `components.nix` in its scope as well:

  ``` nix
  # default.nix
  with import <nixpkgs> { };
  with import <nixexprs> { inherit pkgs; };
  callNURPackage ./release.nix { }
  ```

  ```nix
  # release.nix
  { mkTexDerivation, stdenv, fetchFromGitLab }:

  mkTexDerivation {
    name = "tex-int-test";
    src = fetchFromGitLab {
      # …
    };

    meta = with stdenv.lib; {
      license = licenses.mit;
    };
  }
  ```

* `mkTests`: To be documented
