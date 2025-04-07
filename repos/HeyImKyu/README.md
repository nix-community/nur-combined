# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

# Installation

Follow the installation instructions [here](https://github.com/nix-community/NUR?tab=readme-ov-file#using-packageoverrides)

Then you can reference the packages inside this repository like this:
```nix
# configuration.nix
environment.systemPackages = with pkgs; [
  nur.repos.HeyImKyu.fabric-cli
];
```

or in home-manager:
```nix
# home.nix
home.packages = with pkgs; [
  nur.repos.HeyImKyu.fabric-cli
];
```

If you want to see a whole flake structure that implements the fabric features, check out [this repo](https://github.com/HeyImKyu/fabric-flakes-example)

### Warning

This was at the time built and test with nixos-unstable version, which at the time would have been 25.05.
Some packages might not be available in previous versions.
