# mur (misuzu user repository)

## Setup

```nix
# in your flake
inputs.mur.url = "github:misuzu/mur";

# in your NixOS configuration
imports = [
  # include all mur modules and set up the overlay
  inputs.mur.nixosModules.default
  # set up misuzu's cache (optional)
  inputs.mur.nixosModules.cache
];
```

## License

This project is released under the MIT License. See [LICENSE](./LICENSE).
