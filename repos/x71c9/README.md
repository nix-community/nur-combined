# nur-packages

**x71c9 [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/x71c9/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

### tempesta

The fastest and lightest bookmark manager CLI written in Rust.

```nix
# Basic installation
environment.systemPackages = [ nur.repos.x71c9.tempesta ];

# With shell completion for multiple shells
environment.systemPackages = [ 
  (nur.repos.x71c9.tempesta.override {
    completion = {
      enable = true;
      shells = [ "bash" "zsh" "fish" ];
    };
  })
];
```

**Features:**
- Fast bookmark management
- Multiple output formats
- Configurable shell completion support (bash/zsh/fish)
- NixOS integration

[Full Documentation](./pkgs/tempesta/README.md)

## Usage

Add this repository to your NUR configuration:

```nix
{
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

Then install packages with:
```nix
environment.systemPackages = [ nur.repos.x71c9.PACKAGE_NAME ];
```

