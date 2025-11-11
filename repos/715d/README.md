# NUR Packages

Personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

- `unusedfunc` - Go linter detecting unused functions with /internal awareness

## Installation

After this repository is added to NUR:

```bash
nix-env -iA nur.repos.715d.unusedfunc
```

## Local Testing

```bash
nix-build -A unusedfunc
```
