# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

![Build and populate cache](https://github.com/rapatao/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

## Packages

| Attribute | Description |
| --------- | ----------- |
| `md2`     | CLI to convert Markdown files to PDF, HTML, and text ([upstream](https://github.com/rapatao/md2)) |

## Usage

Once [NUR](https://github.com/nix-community/NUR) is configured:

```console
$ nix-env -f '<nixpkgs>' -iA nur.repos.rapatao.md2
```

Or run a single package without installing it:

```console
$ nix-shell -p 'nur.repos.rapatao.md2'
```

Without NUR configured, build directly from this repo:

```console
$ nix-build -A md2
$ ./result/bin/md2 -version
```
