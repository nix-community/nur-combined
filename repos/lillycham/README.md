# nur-packages

Lilly's [NUR](https://github.com/nix-community/NUR) repository.

| Package | Description |
| --- | --- |
| [dq](https://github.com/lillycham/dq) | Query and manipulate directory trees with jq expressions |
| [hydrus-tagger](https://github.com/lillycham/hydrus-tagger) | Import images into hydrus with WD tagger and OCR tags (macOS) |

## Use

With the NUR overlay: `pkgs.nur.repos.lillycham.<package>`, for example `pkgs.nur.repos.lillycham.dq`.

As a flake: `github:lillycham/nur-packages#<package>`, for example `nix run github:lillycham/nur-packages#dq`.

## Licence

The Nix expressions in this repository are licensed under the MIT licence. See [LICENSE](LICENSE).
Each package's own licence is in its `meta.license`.
