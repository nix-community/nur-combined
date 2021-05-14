[![Linux](https://github.com/jechol/nix-beam/workflows/Linux/badge.svg)](https://github.com/jechol/nix-beam/actions?query=workflow%3A%23Linux%23)
[![macOS](https://github.com/jechol/nix-beam/workflows/macOS/badge.svg)](https://github.com/jechol/nix-beam/actions?query=workflow%3A%23macOS%23)
[![Cachix Cache](https://img.shields.io/badge/cachix-jechol-blue.svg)](https://jechol.cachix.org)

# Nix Packages for Erlang, Elixir

## Installation

### Nix

You must have installed `nix`. See [NixOS install](https://nixos.org/manual/nix/stable/#chap-installation) for more information.

### Cachix (recommended)

Save compile time with binary cache:

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
          beam = import (builtins.fetchTarball
            "https://github.com/jechol/nix-beam/archive/master.tar.gz") { };
        };
      };
  };
}
```

## How to use

Packages can be installed from the `nur` namespace:

```console
$ nix-env -iA nur.repos.beam.erlang.v24_0
$ erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell
"24"

$ nix-env -iA nur.repos.beam.pkg.v23_3.elixir.v1_11_4
$ elixir --version
Erlang/OTP 23 [erts-10.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.11.4 (compiled with Erlang/OTP 23)
```

See? You can use Erlang 24.0 and Elixir 1.11.4 on Erlang 23.3 at the same time!

## Available packages

See available packages with

```shell
$ nix-env -qaP -f https://github.com/jechol/nix-beam/archive/master.tar.gz
```
