# NUR packages

> A personal [NUR](https://github.com/nix-community/NUR) repository packaging my tools for Nix.
> This repository is mainly create for cyber tool.

## Packages

| Package   | Description                                                                            | Source                                                  |
| --------- | -------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| `jwt-tui` | A TUI to decode, tamper with, and re-sign JSON Web Tokens (HMAC, RSA, ECDSA, Ed25519). | [Chiloute/jwt-tui](https://github.com/Chiloute/jwt-tui) |

## Usage

### With Flakes

Add this repo as an input in your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-chiloute.url = "github:Chiloute/nur-packages";
  };

  outputs = { nixpkgs, nur-chiloute, ... }: {
    # Add to your system packages
    environment.systemPackages = [
      nur-chiloute.packages.${system}.jwt-tui
    ];
  };
}
```

Or just run a tool without adding it to your config:

```bash
nix run github:Chiloute/nur-packages#jwt-tui
```

### With NUR (non-flake)

Once published in the [NUR](https://github.com/nix-community/NUR), packages are available as:

```nix
# configuration.nix
environment.systemPackages = [
  pkgs.nur.repos.chiloute.jwt-tui
];
```

### Overlay

You can also use the provided overlay to make the packages available in your nixpkgs instance:

```nix
nixpkgs.overlays = [ nur-chiloute.overlays.default ];
# then use pkgs.jwt-tui as usual
```

## License

The Nix expressions in this repository are released under the [MIT License](LICENSE).
Each packaged tool retains its own upstream license.
