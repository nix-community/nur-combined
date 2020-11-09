**Deprecated:** See [lambdadog/nix-profile-declarative](https://github.com/lambdadog/nix-profile-declarative) for the continuation of my work here. Some of the interesting techniques used in `nix-profile-declarative` are present on a much more basic level in this repo however, so it may still be useful to read through some of my code here, especially [my `user-environment` implementation](./pkgs/user-environment/default.nix).

# `nix-extra`

My personal nix helpers. Also a NUR repository.

See my [nix-config](https://github.com/lambdadog/nix-config)
repository for my personal usage.

## Usage

Can be accessed at `nur.repos.lambdadog` in the
[NUR](https://github.com/nix-community/NUR), or used as an overlay
with something along the lines of:

```nix
import <nixpkgs> {
  overlays = [
    ((import <nixpkgs> {}).callPackage (fetchTarball {
      url = "https://github.com/lambdadog/nix-extra/archive/master.tar.gz";
    }) {}).overlay
  ];
}
```

Note that since we're pulling from master and not using an integrity
hash (like `sha256`), this breaks reproducibility and every build
longer than an hour separated (by default, can be configured with
`tarball-ttl`) will fetch the tarball anew. I personally recommend you
grab a specific revision of `nix-extra` to avoid these issues.

## Utilities

### `pkgs.userEnv`

A trivial-style builder that takes a list of packages and builds a
derivation containing the script `install-user-environment` which will
switch the current user to a user environment containing only those
packages.

The basic building block for declarative user-env management without
taking things quite as far as `home-manager`.

Usage:

```nix
userEnv {
  # Disallows using nix-env imperatively
  static = true;

  packages = [
    hello
  ];
}
```

```sh
$ result/bin/install-user-environment
```

## `pkgs.emacsWithConfig`

A wrapper for `emacsWithPackages` that uses the `-Q` and `--load`
flags to load a config without looking at `~/.emacs.d`.

Introduces some jank. Notably, ruins emacs start profiling.

Usage:

```nix
emacsWithConfig {
  packages = ep: with ep; [ magit ];
  config = ''
    (require 'magit)
  '';
}
```

Instead of a string, `emacsWithConfig` can also take a filepath or a
derivation. If the path or derivation isn't a single file,
`emacsWithConfig` assumes that `init.el` exists in the root of it with
no error checking, so user be warned.

Notes/Tips:

  - To access other files in your configuration directory, you may
    want to call

    ```lisp
    (setq config-home (if load-file-name
                          (file-name-directory load-file-name)
                        default-directory))
    ```

    in your `init.el` to get the root of your config derivation if you
    don't pass it some other way.

  - When passing a path to a nix derivation, the path is copied into
    the nix store before being used, so your config will be read-only.

  - On MacOS, Emacs.app never inherits information from your shell
    env. The `sourceFiles` argument is an optional argument to
    `emacsWithPackages` that allows you to list (bash-compatible)
    files to source so Emacs is able to inherit your shell
    enviroment. This is arguably an unrelated hack, but works and I
    couldn't find anywhere else to put it.
