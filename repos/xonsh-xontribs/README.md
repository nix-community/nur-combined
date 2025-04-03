# nur-packages

**A collection of xonsh-xontribs for [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/drmikecrowe/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-xonsh-xontribs.svg)](https://xonsh-xontribs.cachix.org)

- [Home Page](https://nur.nix-community.org/repos/xonsh-xontribs/)
- [Github](https://github.com/drmikecrowe/nur-packages)

Xonsh is now included in this NUR as well:

- [xonsh 0.18.2](https://github.com/xonsh/xonsh) and [Xonsh Website](https://xon.sh)

The following xontribs are available in this NUR repo:

- [xontrib-abbrevs](https://github.com/xonsh/xontrib-abbrevs)
- [xontrib-bashisms](https://github.com/xonsh/xontrib-bashisms)
- [xontrib-chatgpt](https://github.com/jpal91/xontrib-chatgpt)
- [xontrib-clp](https://github.com/anki-code/xontrib-clp)
- [xontrib-debug-tools](https://github.com/xonsh/xontrib-debug-tools)
- [xontrib-direnv](https://github.com/74th/xonsh-direnv)
- [xontrib-dot-dot](https://github.com/yggdr/xontrib-dotdot)
- [xontrib-fish-completer](https://github.com/xonsh/xontrib-fish-completer)
- [xontrib-gitinfo](https://github.com/dyuri/xontrib-gitinfo)
- [xontrib-jupyter](https://github.com/xonsh/xontrib-jupyter)
- [xontrib-prompt-starship](https://github.com/anki-code/xontrib-prompt-starship)
- [xontrib-readable-traceback](https://github.com/vaaaaanquish/xontrib-readable-traceback)
- [xontrib-sh](https://github.com/anki-code/xontrib-sh)
- [xontrib-term-integrations](https://github.com/jnoortheen/xontrib-term-integrations)
- [xontrib-vox](https://github.com/xonsh/xontrib-vox)
- [xontrib-zoxide](https://github.com/dyuri/xontrib-zoxide)

## Usage

- Follow the [NUR Installation Instructions](https://nur.nix-community.org/documentation/)
- If you've added NUR as an overlay, you can add xontribs like this:

```nix
{ pkgs, ... }:
{
    programs.xonsh =  {
        enable = true;
        extraPackages = ps: with ps; [
            numpy
            xonsh.xontribs.xonsh-direnv
            pkgs.nur.repos.xonsh-xontribs.xontrib-zoxide
        ];
    };
}

```

Probably the easiest way to use this is as a standalone overlay for nixpkgs. In your flake, add both
this repository and nixpkgs. Then apply this overlay when you import the nixpkgs overlay.

```
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/unstable";
    xonsh-xontrib.url = "github:drmikecrowe/nur-packages";
  };

  outputs = { self, nixpkgs, xonsh-xontrib, ... }@inputs: {
  let
    packageSet = system: (import nixpkgs { inherit system; overlays = [ xonsh-xontrib.overlays ]; };
  in {
    devShells.x86_64-linux = let
        pkgs = packageSet "x86_64-linux";
    in {
      buildInputs = with pkgs; [
        xonsh.override {
          extraPackages = (ps: [
            ps.xonsh-direnv
            ps.xontrib-vox
          ]);
        }
      ];
    };
  };
}
```

You should be able to use this similarly wherever you import nixpkgs by setting it as one over the overlays.

## Cachix Public Keys

- [https://xonsh-xontribs.cachix.org](https://xonsh-xontribs.cachix.org)
- `xonsh-xontribs.cachix.org-1:LgP0Eb1miAJqjjhDvNafSrzBQ1HEtfNl39kKtgF5LBQ=`

## Contributing

This is still very much a work in progress, and will be enhanced over time.  However, the shell for a given xontrib is created by the `create-xontrib-overlay.xsh` script.  This will build a shell with a possible build setup for the xontrib that you can test.  Submit a PR and we will expand this repo with as many xontribs as we can.
