# Nix User Repository

This repository contains Charm’s [Nix User Repository](https://github.com/nix-community/NUR).

![Build and populate cache](https://github.com/charmbracelet/nur/workflows/Build%20and%20populate%20cache/badge.svg)

## Usage
### With flake
#### NixOS

Add the flake as an input in your `flake.nix` file and include the desired module in your configuration:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  nur = {
    url = "github:charmbracelet/nur";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = { self, nixpkgs, nur, ... }:
{
  nixosConfigurations.example = nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      nur.nixosModules.crush
      { programs.crush.enable = true; }
    ];
  };
}
```

#### Home Manager

Add the flake as an input and include the desired module in your Home Manager configuration:

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  nur = {
    url = "github:charmbracelet/nur";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = { self, nixpkgs, nur, home-manager, ... }:
{
  homeConfigurations.user = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      nur.homeModules.crush
      { programs.crush.enable = true; }
    ];
  };
}
```

## Available Modules

- **NixOS Modules**:
  - `nixosModules.crush`: Provides NixOS integration for the `crush` tool.

- **Home Manager Modules**:
  - `homeModules.crush`: Provides Home Manager integration for the `crush` tool.

## Configuration Options

### programs.crush

- `enable` (boolean): Enable the `crush` tool (default: `false`).
- `package` (package): Override the package used for `crush`. Defaults to the package provided by this repository.
- `settings` (attribute set): Additional configuration settings for `crush`.

### Example: Override Package

```nix
programs.crush = {
  enable = true;
  package = pkgs.callPackage /path/to/custom/crush {};
};
```

---

Part of [Charm](https://charm.sh).

<a href="https://charm.sh/"><img alt="The Charm logo" src="https://stuff.charm.sh/charm-badge.jpg" width="400"></a>

Charm热爱开源 • Charm loves open source
