nix-build -E 'with import <nixpkgs> {}; python3.withPackages(p: with p; [(callPackage ./default.nix {})])' --max-jobs 1 --cores 1
