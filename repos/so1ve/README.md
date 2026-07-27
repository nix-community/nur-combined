# so1ve/nur-packages

Ray's personal [NUR](https://github.com/nix-community/NUR) repository

## NUR

After enabling NUR, install a package through its repository attribute:

```nix
environment.systemPackages = [
  pkgs.nur.repos.so1ve.ab-download-manager
];
```

Published modules and overlays are available below
`pkgs.nur.repos.so1ve.modules` and `pkgs.nur.repos.so1ve.overlays`.

## Flake

Run or install a package directly:

```bash
nix run github:so1ve/nur-packages#ab-download-manager
nix profile install github:so1ve/nur-packages#ab-download-manager
```

Or add the repository as a flake input:

```nix
{
  inputs.so1ve-nur = {
    url = "github:so1ve/nur-packages";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Packages are exposed through `packages`, modules through `homeModules`, and
overlays through `overlays`.

## Packages

| Attribute | Documentation |
| --- | --- |
| `ab-download-manager` | [Usage](pkgs/ab-download-manager/README.md) |
