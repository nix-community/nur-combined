# Neovim Nix

This is a wrapper nix expression around the neovim package. It adds a few enhancements to the override API:

- Support colocating plugin-specific vimrc with their corresponding plugins. (See `examples/example.nix`)
- Support specifying settings for [coc plugins](https://github.com/neoclide/coc.nvim) (See `examples/example_coc.nix`)

# Usage

## Niv

First setup [niv](https://github.com/nmattia/niv), and initialize your project. Then follow instructions below in your project folder:

1. Add the package:

```bash
niv add rencire/neovim-nix
```

2. Use the `neovim-nix` wrapper expression. Make sure to pass in `lib` and `neovim` from `nixpkgs`.

Here's a sample `default.nix` expression with the `neovim-nix` wrapped derivation:

```
{ sources ? import ./nix/sources.nix
, pkgs ? import sources.nixpkgs {}
, neovim ? import sources.neovim-nix { inherit (pkgs) lib neovim; }
}:

neovim.override {
  configure = {
    customRC = ''
      set number
    '';
    packages.main = with pkgs.vimPlugins; [
      start = [
        {
          plugin = surround;
          vimrc = ''
            "Insert specific vimrc config for `surround` vim plugin here
          '';
        }
      ];
    }
}

```

3. Build your derivation. i.e.:

```bash
nix-build default.nix

```

4. Run neovim binary. e.g.:

```bash
./result/bin/nvim
```

See `examples` folder for more details.

### NUR

<todo>

## Troubleshoot

Check the output script sourced by neovim:

```bash
nix-build default.nix && ./result/bin/nvim +scr1
```

## Background/Rationale

### `vimrc` attribute for `vimPlugins`

The [neovim package](https://github.com/NixOS/nixpkgs/blob/20.03-beta/pkgs/applications/editors/neovim/wrapper.nix) is using the API provided by [vim-utils](https://github.com/NixOS/nixpkgs/blob/20.03-beta/pkgs/misc/vim-plugins/vim-utils.nix) to specify vim plugins and custom `vimrc`.

For example, one might specify their neovim configuration like so:

```
neovim.override {
  configure = {
    customRC = ''
      "General vimrc config

      "Specific vimrc config for plugin 1

      "Specific vimrc config for plugin 2

      "Specific vimrc config for plugin 3

      "Specific vimrc config for plugin 4
    '';
    packages.main = with pkgs.vimPlugins; {
      start = [
        plugin-0-deriv
        plugin-1-deriv
        plugin-2-deriv
      ];
      opt = [ plugin-3-deriv ]
    };
    plug.plugins = with pkgs.vimPlugins; [
      plugin-4-deriv
    ];
  };
}
```

However, as the number of plugins grow, one might want to group the plugin-specific vimrc together with its corresponding plugin derivation for better organization.

With our new wrapper nix expression, we can specify our neovim configuration like so:

```
neovim.override {
  configure = {
    customRC = ''
      "General vimrc config
    '';
    packages.main = with pkgs.vimPlugins; {
      start = [
        plugin-0-deriv
        {
          plugin = plugin-1-deriv;
          vimrc = ''
            "Specific vimrc config for plugin 1
          '';
        }
        {
          plugin = plugin-2-deriv;
          vimrc = ''
            "Specific vimrc config for plugin 2
          '';
        }
      ];
      opt = [
        {
          plugin = plugin-3-deriv;
          vimrc = ''
            "Specific vimrc config for plugin 3
          '';
        }
      ];
    ];

    plug.plugins = with pkgs.vimPlugins;
      [
        {
          plugin = plugin-4-deriv;
          vimrc = ''
            "Specific vimrc config for plugin 4
          '';
        }
      ];
    };
  };
}
```

Notes:

- Here `plugin-0-deriv` doesn't need any vimrc, hence just specifying the derviation is fine.
  For each of the other plugins that do require a vimrc, we specify an `attribute set` with the properties `plugin` and `vimrc`.
- Code above are just examples. See "Usage" section for details on working code.

### `settings` attribute for coc `vimPlugins`

<todo>

## Notes

```
neovim.override {
  ... # can still override top level fields of attribute set
  configure = {

    # Vim Plug plugins
    plug.plugins = [];

    # Native vim plugins
    packages.BasePackage = {
      start = [
        <plugin-1>
	{
	  plugin = plugin2;
	  vimrc = ''
	    <insert vimrc for this plugin here>
	  '';
	}
      ];
      opt = [];
    };

  };
}


```

```
plugins = [
  <plugin_deriv>
  {
    plugin = <plugin_deriv>;
    vimrc = ''
      <insert vimscript specific to plugin here>
    '';
  }
  ...
]

```

## TODO

- [x] create initial interface for specifying plugins
- [] doc: formalize plugin grammar
- [x] feat: vimrc from 'packages' generated in order of declaration (ordered via package attribute name).
  - to debug generated vimrc: nix-build example.nix && ./result/bin/nvim +scr1
- [x] fix: extra leading whitespace in vimrc declared in configuration
- [x] feat: vimrc from 'vimPlug'
- [] doc: add instructions for using [NUR](https://github.com/nix-community/NUR)
- [] doc: add support for [nix flakes](https://github.com/NixOS/rfcs/pull/49) once its stable. consider deprecating niv workflow then.
- [] docs: add table of contents

## Development

### 0) Prerequisites

- [Nix](https://nixos.org/nix/)
- [Niv](https://github.com/nmattia/niv)
- [direnv](https://github.com/direnv/direnv) (optional)
  - allows auto loading packages when navigating to this directory
  - can install via nix: `nix-env -i direnv`

### 1) Update nixpkgs version to latest branch.

linux:

```
niv update nixpkgs -b nixpkgs-19.09
```

macos:

```
niv update nixpkgs -b nixpkgs-19.09-darwin
```

### 2) Add project packages

If package is available in nix, add it to `shell.nix`

```bash
with import ./nix;
  mkShell {
    buildInputs = [
      lefthook # for managing git hooks
      <insert pkg1 here>
      <insert pkg2 here>
    ];
  }
```

### 3) Install packages

With `direnv` installed:

1. Uncomment `use_nix` line in `.envrc`.
2. Enable direnv:

```
direnv allow
```

Alternatively, without using `direnv`, just use `nix-shell`:

```
nix-shell
```

### 4) Setup git hooks

Run:

```
lefthook install
```
