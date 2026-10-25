# nur-lazycat-cloud-client-flake

**My personal [NUR](https://github.com/nix-community/NUR) repository**

NUR packages for the [LazyCat Cloud desktop client](https://lazycat.cloud)
(懒猫微服), a micro-server platform for personal cloud services.

## Packages

| Attribute | Description |
|-----------|-------------|
| `lazycat-cloud-client` | LazyCat Cloud desktop client (unfree, `x86_64-linux`) |

## Usage

Add NUR to your flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

Then either use the package directly:

```nix
environment.systemPackages = [
  pkgs.nur.repos.zerokaze420.lazycat-cloud-client
];
```

or use the NixOS / Home Manager modules:

```nix
nur.repos.zerokaze420.nixosModules.lazycat-cloud-client
nur.repos.zerokaze420.homeModules.lazycat-cloud-client
```

The package is unfree. Enable it in your configuration, or pass
`NIXPKGS_ALLOW_UNFREE=1` when using `nix` commands with `--impure`.

## Layout

```text
default.nix                          # NUR package set entry point
pkgs/lazycat-cloud-client/default.nix # package expression
nixos-modules/                       # NixOS module
home-modules/                        # Home Manager module
```

## License

The Nix expressions are licensed under the MIT license. The packaged
LazyCat Cloud client itself is unfree; see the upstream license terms.
