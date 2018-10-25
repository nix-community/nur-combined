nix library extension, containing sophisticated script and code generator functions.

# How to include as overlay

```
{ config, pkgs, ... }:
let

  # fetch the repository
  # ------------------
  # nix-prefetch-git is your friend to create this part.
  nix-writers = (import <nixpkgs> {}).fetchgit {
    url    = "https://cgit.krebsco.de/nix-writers";
    rev    = "c8d71ce6acbae124a7bc162323442979a1d6df06";
    sha256 = "0r1p34a3jvm55v5sbkfbjpqcld2cbdrvc5685g723b1frhw666ag";
  };

in {

  # include the repository as overlay
  nixpkgs.config.packageOverrides = import "${nix-writers}/pkgs" pkgs;

  ...

}
```

# How to use the scripts

once you've included the nix-writers as overlay you can use the scripts to create to create binaries (for example)

```
  environment.systemPackages = with pkgs; [

    # Haskell example
    (writeHaskellPackage "nix-writers-example-haskell" {
      executables."nix-writers-example-haskell".text = ''
        main = print "this is a writeHaskell example"
      '';
    })

    # C example
    (writeC "nix-writers-example-c" {
      destination = "/bin/nix-writers-example-c";
    } ''
      int main() { printf("this is a writeC example!\n"); }
    '')

    # Dash example
    (writeDashBin "nix-writers-example-dash" ''
      echo "this is a writeDash example!"
    '')

  ];
```
