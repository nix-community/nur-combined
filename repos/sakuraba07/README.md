# NUR Packages

My personal [Nix User Repository (NUR)](https://github.com/nix-community/NUR) packaging [`oh-my-pi`](https://github.com/can1357/oh-my-pi) (binary name: `omp`), an AI coding agent for the terminal.

> **Disclaimer & Acknowledgements:** This is a personal, unofficial repository that packages tools for the Nix ecosystem. It includes excellent software created by other developers. All rights, credits, and gratitude for the original software belong to their respective authors. These Nix packages are maintained independently out of respect and appreciation for the original projects.

## Packages

- `omp`: [can1357/oh-my-pi](https://github.com/can1357/oh-my-pi) — an AI coding agent for the terminal, forked from [Pi](https://github.com/badlogic/pi-mono).

### Why a prebuilt binary?

Upstream is a TypeScript (Bun) + Rust (N-API) + Bazel project that releases new builds almost daily. Vendoring its Cargo/Bun lockfiles for a from-source Nix build would need constant hash churn to keep up, so this package instead fetches the same single-file executables (`omp-linux-x64`, `omp-darwin-arm64`, ...) that upstream's own `curl -fsSL https://omp.sh/install | sh` script installs, verified against the release's `SHA256SUMS.txt`.

## Usage

### Using Flakes

Add this repository to your `flake.nix` inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    my-nur = {
      url = "github:<YOUR_USERNAME>/<YOUR_REPO>";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, my-nur, ... }: {
    nixosConfigurations.myMachine = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ my-nur.overlays.default ];
          environment.systemPackages = [
            my-nur.packages.x86_64-linux.omp
          ];
        })
      ];
    };
  };
}
```

### Using Legacy NUR

If you are using the traditional `nur` package:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
    inherit pkgs;
  };
in
{
  environment.systemPackages = [
    nur.repos.<YOUR_USERNAME>.omp
  ];
}
```

### Supported systems

`x86_64-linux`, `aarch64-linux`, `aarch64-darwin`. (`x86_64-darwin` binaries are still fetched by `pkgs/omp/default.nix` when used with an older nixpkgs, but the flake's system list omits it because nixpkgs-unstable has dropped `x86_64-darwin` support.)
