[![Build and populate cache](https://github.com/jechol/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)](https://github.com/jechol/nur-packages/actions)
[![Cachix Cache](https://img.shields.io/badge/cachix-jechol-blue.svg)](https://jechol.cachix.org)

## Nix Packages for Erlang, Elixir, LFE

## Installation

> You must have installed `nix`. See https://nixos.org for more information.

First include NUR in your `packageOverrides`:

To make NUR accessible for your login user, add the following to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

## How to use

Then packages can be used or installed from the NUR namespace.

```console
$ nix-shell -p nur.repos.jechol.beam.main.erlangs.erlang_23_0
nix-shell> erl -version
Erlang (SMP,ASYNC_THREADS,HIPE) (BEAM) emulator version 11.0
```

or

```console
$ nix-env -f '<nixpkgs>' -iA nur.repos.jechol.beam.main.erlangs.erlang_23_0
```

 `beam.main` includes only combinations of major versions of Erlang/Elixir.

 On the other hands, `beam.all` includes every combinations and other tools. For example,
 * `beam.all.erlangs.erlang_22_3_javac_odbc` : Erlang 22.3 with support for Java and ODBC
 * `beam.all.packages.erlang_22_3.elixirs.elixir_1_10_4` : Elixir 1.10.4 running on Erlang 22.3
 * `beam.all.packages.erlang_22_3.hex` : Hex running on Erlang 22.3

