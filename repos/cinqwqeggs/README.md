# quinova-nur-packages

A personal [NUR (Nix User Repository)](https://github.com/nix-community/NUR) maintained by CinQwQeggs01.

---

## Binary Cache (Cachix)

To avoid building packages from source, you can use the provided Cachix binary cache.

### Option 1: NixOS configuration

Add the following to your NixOS configuration:
```nix
nix.settings = {
  substituters = [
    "https://quinova-nur.cachix.org"
  ];
  trusted-public-keys = [
    "quinova-nur.cachix.org-1:XXtQKJvYMH9gf0EBgUtmHBaW+wKbpOranZs1oVZ7SSg="
  ];
};
```

### Option 2: `cachix` CLI
```bash
cachix use quinova-nur
```

---

## Usage

### 1. Add NUR to your flake inputs
```nix
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### 2. Enable the NUR overlay (NixOS)
```nix
# In your nixosConfigurations modules:
modules = [
  nur.modules.nixos.default
  # ...
];
```

### 3. Install packages from this repo
```nix
environment.systemPackages = [
  pkgs.nur.repos.cinqwqeggs.<package-name>
];
```

---

## License

MIT
