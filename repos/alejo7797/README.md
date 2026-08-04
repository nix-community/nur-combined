# Quickstart

## Pure Nix (with [flakes](https://wiki.nixos.org/wiki/Flakes#Setup) enabled)

These should work out of the box on any Linux or macOS host. (Maybe even [Windows](https://github.com/nix-community/NixOS-WSL)?)

Pretend that you've just run the following:
```bash
nix registry add alejo7797 https://codeberg.org/alejo7797/nix-expressions/archive/main.tar.gz
```

### [SnapPy](https://snappy.computop.org)
```bash
nix run alejo7797\#snappy-topology
```

#### Features
- Access [special features](https://snappy.computop.org/installing.html#sagemath) of SnapPy depending on Sage
- Access Regina's rich [Python interface](https://regina-normal.github.io/docs/python.html)

### [KnotJob](https://www.maths.dur.ac.uk/users/dirk.schuetz/knotjob.html)
```bash
nix run alejo7797\#knotjob
```

## NixOS with flakes
```nix
# /etc/nixos/flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    alejo7797 = {
      url = "https://codeberg.org/alejo7797/nix-expressions/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    {
      nixosConfigurations.<name> = nixpkgs.lib.nixosSystem {
        modules = [
          {
            nixpkgs.overlays = [
              inputs.alejo7797.overlays.math
            ];

            environment.systemPackages = with pkgs; [
              knotjob
              regina-normal
              sage
              snappy-topology
            ];
          }
          ./configuration.nix  # <-- the rest of your configuration
        ];
      };
    };
}
```

## NUR etc.
Also available on the [Nix User Repository](https://nur.nix-community.org/repos/alejo7797/), if that's your kind of thing.
