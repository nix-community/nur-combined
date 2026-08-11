# In a pre-existing flake

To install `bun2nix` in an already existing bun project with a `flake.nix`, the following steps are recommended:

## 1. Source the `bun2nix` repo

Add the `bun2nix` flake to your inputs as follows:

```nix
bun2nix.url = "github:nix-community/bun2nix";
bun2nix.inputs.nixpkgs.follows = "nixpkgs";
```

## 1.5. (Optional) Use the binary cache

The `bun2nix` executable typically takes a while to compile, which is typical for many Rust programs, hence, hence, it may be a good idea to use the [nix-community](https://nix-community.org/cache/) cache.

To add it include the following in your `flake.nix`.

```nix
nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
};
```

## 2. Get a `bun2nix` binary

### Recommended: Use the NPM package

`bun2nix` has a cross-platform web-assembly based NPM package available for usage. This should
be the default choice as it allows those who do not have nix installed to work on your project
and keep the generated `bun.nix` file up to date.
Simply install and run it with:

```
bun install --dev bun2nix
bunx bun2nix
```

### Add the binary to your environment with nix

Alternatively, add the native `bun2nix` CLI program into your developer environment by adding it to your [dev-shell](https://fasterthanli.me/series/building-a-rust-service-with-nix/part-10).

```nix
devShells.default = pkgs.mkShell {
  packages = with pkgs; [
    bun
    bun2nix.packages.${system}.default
  ];
};
```

> NOTE: the `system` variable can be gotten in a variety of convenient ways - including [flake-utils](https://github.com/numtide/flake-utils) or [nix-systems](https://github.com/nix-systems/nix-systems).

## 3. Use the binary in a bun `postinstall` script

To keep the generated `bun.nix` file produced by `bun2nix` up to date, add `bun2nix` as a `postinstall` script to run it after every bun operation that modifies the packages in some way.

Add the following to `package.json`:

```json
"scripts": {
    "postinstall": "bun2nix -o bun.nix"
}
```

## 4. Build your package with Nix

Finally, a convenient package builder is exposed inside `bun2nix` - `mkDerivation`.

Add the following to `flake.nix`:

> A nice way to do this might be with the [overlay](./overlay.md)

```nix
my-package = pkgs.callPackage ./default.nix {
    inherit bun2nix.packages.${system}.default;
};
```

And place this in a file called `default.nix`

```nix
{ bun2nix, ... }:
bun2nix.mkDerivation {
  pname = "bun2nix-example";
  version = "1.0.0";

  src = ./.;

  bunNix = ./bun.nix;

  module = "index.ts";
}
```

A list of available options for `mkDerivation` can be seen at [the building packages page](./building-packages.md), along with other useful things for building bun packages.
