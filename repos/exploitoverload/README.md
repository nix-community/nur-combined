# PwNixOS-Packages: Hacking tools for PwNixOS

![Build and populate cache](https://github.com/exploitoverload/PwNixOS-Packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-pwnixos-blue.svg)](https://pwnixos.cachix.org)

## List of Packages:

* Responder (v3.1.3.0) (database file and logs in /tmp) -> Functional but WiP
* impacket (impacket_0_10_0)
* BloodHound (v4.3.1) (running with steam-run, running natively not working...)
* bloodhound-python (v1.0.1)
* seclists (2023.2)
* psudohash (commit 2d586dec8b5836546ae54b924eb59952a7ee393c)
* ADCSKiller (commit d74bfea91f24a09df74262998d60f213609b45c6)
* polenum (1.6.1)

## How to install packages - (for testing purposes)

Two Options:

1. Build

```zsh
nix-build -A <package>
```
A folder named result is created, which contains the result of the package derivation. The structure is similar to the linux file tree, the `./bin` folder contains the executables and the `./share/<package>` folder contains the source code of the package. To run the package, simply run the binaries found in the `./bin` folder.

2. Install 

```zsh
nix-env -if default.nix
```
In this other way, all the packages in this repo are installed in the user's profile, so they will be available as any other package in the system. 

To list the packages installed in the profile, or to remove a package, you can use the following commands:

```zsh
nix-env -q # List installed packages

nix-env -e <package> # Uninstall a package
```
