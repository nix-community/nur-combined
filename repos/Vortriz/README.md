# Vortriz's packages

This is a collection of package expressions and modules for use in my own [dotfiles](https://github.com/Vortriz/dotfiles). The auto-updating packages are managed via [tack](https://github.com/manic-systems/tack).

> [!CAUTION]
> Packages in this repository may be bleeding-edge, meaning they are automatically updated daily with no manual review step. Make sure you understand the stability and security implications before using them.

## Usage

Add this repository to your flake inputs:

```nix
# In your flake.nix

{
    inputs = {
        # Your Nixpkgs input
        nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    
        vpkgs.url = "github:Vortriz/vpkgs";
        
        # Other inputs
        # ...
    };
}
```

Then all the packages can be used directly from inputs, through `legacyPackages`:

```nix
{ 
    inputs,
    ...
}: {
    # For this to be valid, you need `inputs` in the argset above and vpkgs
    # to be in your `inputs`, as demonstrated in the flake.nix example. You 
    # will also need `inputs` to be in your `nixosSystem` call's `specialArgs`
    # or else you will not be able to access `inputs` in your modules.
    environment.systemPackages = [
        inputs.vpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.doi2bib3 # example
        inputs.vpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.espansoPackages.lower-upper # example
    ];
}
```

## Package list

### Regular packages

Available via `legacyPackages` as well as the `default` overlay.

| Package                                                                                                                            | Status       |
| ---------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| [`doi2bib3`](https://github.com/archisman-panigrahi/doi2bib3)                                                                      | Auto updated |
| [`libfprint-focaltech-2808-a658`](https://github.com/Varrkan82/RTS5811-FT9366-fingerprint-linux-driver-with-VID-2808-and-PID-a658) | Pinned       |

### Espanso packages

Available only through `legacyPackages.espansoPackages.<package>`.

| Package                                                                         | Status |
| ------------------------------------------------------------------------------- | ------ |
| [`actually-all-emojis-spaces`](https://github.com/jobiewong/espanso-emojis)     | Pinned |
| [`greek-letters-improved`](https://github.com/jpmvferreira/espanso-mega-pack)   | Pinned |
| [`lower-upper`](https://github.com/anthonygraignic/espanso-package-lower-upper) | Pinned |
| [`math-symbols`](https://github.com/jpmvferreira/espanso-mega-pack)             | Pinned |
| [`super-sub-scripts`](https://github.com/jpmvferreira/espanso-mega-pack)        | Pinned |

### Fonts

Available only through `legacyPackages.fonts.<package>`.

| Package                                                                                      | Status |
| -------------------------------------------------------------------------------------------- | ------ |
| [`HelveticaNeueCyr`](https://github.com/Vortriz/fonts)                                       | Pinned |
| [`SFMono-Nerd-Font-Ligaturized`](https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized) | Pinned |

### Yazi plugins

Available only through `legacyPackages.yaziPlugins.<package>`.

| Package                                                                           | Status       |
| --------------------------------------------------------------------------------- | ------------ |
| [`bunny`](https://github.com/stelcodes/bunny.yazi)                                | Auto updated |
| [`custom-shell`](https://github.com/AnirudhG07/custom-shell.yazi)                 | Auto updated |
| [`enhance-piper`](https://github.com/boydaihungst/enhance-piper.yazi)             | Auto updated |
| [`file-extra-metadata`](https://github.com/boydaihungst/file-extra-metadata.yazi) | Auto updated |
| [`what-size`](https://github.com/pirafrank/what-size.yazi)                        | Auto updated |

### Zotero addons

Available only through `legacyPackages.zoteroAddons.<package>`.

| Package                                                                      | Status                         |
| ---------------------------------------------------------------------------- | ------------------------------ |
| [`zotero-better-bibtex`](https://github.com/retorquere/zotero-better-bibtex) | Auto updated (stable releases) |
| [`zotero-scipdf`](https://github.com/syt2/zotero-scipdf)                     | Auto updated (stable releases) |
| [`zotlit`](https://github.com/aidenlx/zotlit)                                | Auto updated (stable releases) |
| [`zotmoov`](https://github.com/wileyyugioh/zotmoov)                          | Auto updated (stable releases) |

## Modules

- Zotero - `inputs.vpkgs.homeModules.zotero` ([source](/modules/home-manager/zotero.nix))

## Credits

Big thanks to the folks over at [manic-systems](https://github.com/manic-systems/) for creating tack and to NotAShelf for his tack-managed [nyxexprs](https://github.com/NotAShelf/nyxexprs), which I used as reference for migration to tack.
