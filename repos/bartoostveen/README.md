# nix-packages

Bart's packages for the Nix package manager that can't/won't get upstreamed.

## Usage

### Using `nix-env`

#### Using channels

Execute the following commands:

```bash
nix-channel --add git+https://git.bartoostveen.nl/bart/nix-packages.git
nix-channel --update
```

Then, import like so:

```nix
import <bart-packages> { }
```

#### Using fetchers

```nix
import (pkgs.fetchFromForgejo {
  domain = "git.bartoostveen.nl";
  owner = "bart";
  repo = "nix-packages";
  rev = "<insert revision here>";
  hash = ""; # rebuild, then copy-paste actual hash
}) { inherit pkgs; }
```

### Using flakes

#### Using packages directly

##### `flake-parts`

```nix
inputs = {
  bart-packages = {
    url = "git+https://git.bartoostveen.nl/bart/nix-packages.git";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

perSystem = { inputs', ... }: {
  my.attribute.here = inputs'.bart-packages.packages;
};
```

##### Generic flakes

```nix
{
  inputs = {
    bart-packages = {
      url = "git+https://git.bartoostveen.nl/bart/nix-packages.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ ... }: {
    my.attribute.here = inputs.bart.packages.${system}.packages;
  };
}
```

#### Using overlays

```nix
import inputs.nixpkgs {
  overlays = [
    inputs.bart-packages.overlays.default
  ];
}
```

### Configuration

You may configure this package set through overlays:

```nix
import inputs.nixpkgs {
  overlays = [
    (_: _: {
      _bartPackages = {
        suppressSystemWarning = true;
        prefix = "bart";
      };
    })
    # Optional: if packages not yet imported otherwise
    inputs.bart-packages.overlays.default
  ]
}
```

> [!TIP]
> There is `inputs.bart-packages.overlays.suppressSystemWarning` for convenience as well.

> [!NOTE]
> `prefix` means the attribute name the package set lives at when importing them. E.g. setting it to `"foo"` makes these packages available at `pkgs.foo`, keeping it `null` makes these packages available as an overlay, possibly replacing other packages.

## Binary cache

This is a work in progress.

## Package search

You may make use of [my NüschtOS Search instance](https://search.boostveen.nl/packages?scope=bart-packages) to find packages (<https://search.boostveen.nl/packages?scope=bart-packages>, [unstable](https://test.search.boostveen.nl/packages?scope=bart-packages)). This index is updated regularly, at least once a week.

## License

This package repository is licensed under the [MIT license](./LICENSE).
