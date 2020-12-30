# Firefox addons

Nix has been making a transition into slowly hardening firefox profiles, starting with your addons list

## Installation

### Requirements

* [firefox](https://www.mozilla.org/en-US/firefox/download/thanks/)
* [jq](https://github.com/stedolan/jq)
* [nix](https://nixos.org)

### Generating addons

To get your own addons list, copy `generate-addons.sh` and `findSlugs.jq` into an empty directory, then exectute `generate-addons.sh` in the new directory.

## Usage

The [nixpkgs manual](https://nixos.org/manual/nixpkgs/unstable/#sec-firefox) has a guide on how to integrate your generated addons, but if you want a quick tryout:

```nix
{ pkgs ? import <nixpkgs> {}}:
let
  inherit (pkgs) wrapFirefox firefox-unwrapped;
  addons = import ./path/to/generated/addons { inherit pkgs; };
  inherit (builtins) attrValues;
in
  wrapFirefox firefox-unwrapped {
    nixExtensions = attrValues addons;
  }
