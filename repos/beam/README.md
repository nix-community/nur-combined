[![Linux](https://github.com/jechol/nix-beam/workflows/Linux/badge.svg)](https://github.com/jechol/nix-beam/actions?query=workflow%3A%22Linux%22)
[![macOS](https://github.com/jechol/nix-beam/workflows/macOS/badge.svg)](https://github.com/jechol/nix-beam/actions?query=workflow%3A%22macOS%22)
[![Cachix Cache](https://img.shields.io/badge/cachix-jechol-blue.svg)](https://jechol.cachix.org)

# Nix Packages for Erlang, Elixir

## Installation

### Nix

You must have installed `nix`. See [NixOS install](https://nixos.org/manual/nix/stable/#chap-installation) for more information.

### Cachix (optional)

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
$ nix-env -iA nur.repos.beam.erlang.v23_0
$ erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell
"23"

$ nix-env -iA nur.repos.beam.pkg.v22_0.elixir.v1_11_0
$ elixir --version
Erlang/OTP 22 [erts-10.4] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Elixir 1.11.0 (compiled with Erlang/OTP 22)
```

See? You can use Erlang 23 and Elixir 1.11 on Erlang 22 at the same time!

### Included packages

* Erlang: Latest 3 major versions. i.e. includes 23.0, but not 23.1 or 23.0.1
* Elixir: Latest 5 minor versions for each Erlang. i.e. includes 1.11.0, but not 1.11.1
* Rebar3: Latest Rebar3 for each Erlang.
* Rebar: Rebar 2.6.4 for each Erlang. 
