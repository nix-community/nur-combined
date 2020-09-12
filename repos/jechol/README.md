[![Linux](https://github.com/jechol/nur-packages/workflows/Linux/badge.svg)](https://github.com/jechol/nur-packages/actions?query=workflow%3A%22Linux%22)
[![macOS](https://github.com/jechol/nur-packages/workflows/macOS/badge.svg)](https://github.com/jechol/nur-packages/actions?query=workflow%3A%22macOS%22)
[![Cachix Cache](https://img.shields.io/badge/cachix-jechol-blue.svg)](https://jechol.cachix.org)

# Nix Packages for Erlang, Elixir, LFE

## Installation

### Nix

You must have installed `nix`. See [NixOS install](https://nixos.org/manual/nix/stable/#chap-installation) for more information.

### Cachix (optional)

Save compile time with binary caches:

```console
$ nix-env -iA cachix -f https://cachix.org/api/v1/install
$ cachix use jechol
```

### Configuration

Include NUR(Nix User Repository) to `~/.config/nixpkgs/config.nix`:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball
      "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;

        repoOverrides = {
          jechol = import (builtins.fetchTarball
            "https://github.com/jechol/nur-packages/archive/master.tar.gz") { };
        };
      };
  };
}
```

## How to use

Packages can be installed from the `nur` namespace:

```console
$ nix-env -iA nixpkgs.nur.repos.jechol.beam.main.erlangs.erlang_23_0
$ erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell
"23"

$ nix-env -iA nixpkgs.nur.repos.jechol.beam.main.packages.erlang_22_0.elixirs.elixir_1_10_0
$ elixir --version
Erlang/OTP 22 [erts-10.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.10.0 (compiled with Erlang/OTP 22)
```

See? You can use Erlang 23 and Elixir 1.10 on Erlang 22 at the same time!

### Included packages

`beam.main` includes major combinations of Erlang/Elixir and pre-built packcages are cached by **Cachix**.

On the other hands, `beam.all` includes every combinations, but not cached.

For example,

- `beam.main.packages.erlang_23_0.elixirs.elixir_1_10_0` : Elixir 1.10.0 on Erlang 23.0 (cached)
- `beam.all.packages.erlang_22_3.elixirs.elixir_1_10_4` : Elixir 1.10.4 on 22.3 (not cached)
- `beam.all.erlangs.erlang_22_3_javac_odbc` : Erlang 22.3 with support for Java and ODBC (not cached)

You can navigate through packages with `nix repl`:

```
$ nix repl '<nixpkgs>'

nix-repl> nur.repos.jechol.beam.all.packages.erlang_20_3_8_9<TAB>
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_nox
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_javac
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_nox_odbc
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_javac_nox
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_odbc
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_javac_nox_odbc
nur.repos.jechol.beam.all.packages.erlang_20_3_8_9_javac_odbc
```

# TODO (Contributions are welcome)

- [x] Include all Erlang releases
- [x] Include all Elixir releases
- [x] Automate above tasks with scripts or Github actions
