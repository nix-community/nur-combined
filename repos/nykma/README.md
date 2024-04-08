# My Nix packages definition

![Build and populate cache](https://github.com/nykma/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-nykma-blue.svg)](https://nykma.cachix.org)

## How to use

Follow [NUR's official guide](https://github.com/nix-community/nur#how-to-use) to intergrate all NUR repos in your system.

Or, if you only want to install my repo:

```nix
{ # flake.nix
  nixConfig = {
    extra-substituters = [
      "https://nykma.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nykma.cachix.org-1:z04hZH9YnR1B2lpLperwiazdkaT5yczgOPa1p/NHqK4="
    ];
  };

  inputs = {
    # ...
    nykma.url = "github:nykma/nur-packages";
    nykma.inputs.nixpkgs.follows = "nixpkgs";
    # ...
  };

  outputs = { self, nykma, ... } @ inputs: {
    # ...
  }
}
```

```nix
# your-system/configuration.nix
nix.settings = {
  extra-substituters = [
    "https://nykma.cachix.org"
  ];

  extra-trusted-public-keys = [
    "nykma.cachix.org-1:z04hZH9YnR1B2lpLperwiazdkaT5yczgOPa1p/NHqK4="
  ];
};
```

## LICENSE

MIT for all `.nix` and `.patch` files I wrote. See `LICENSE` file for more info.
