# nur-packages

My personal [NUR](https://github.com/nix-community/NUR) repository.

## Packages

### ChipWhisperer

[ChipWhisperer](https://github.com/newaetech/chipwhisperer) is a toolchain for
side-channel power analysis and glitching attacks.

The package in nixpkgs is currently marked broken because ChipWhisperer pins
`numpy==1.26.4` (numpy 1.x), while nixpkgs only supports numpy 2.x. This repo
builds ChipWhisperer inside a Python 3.12 package set where numpy is
overridden to `numpy_1` (NumPy 1.26.4). Python 3.12 is required because
`numpy_1` doesn't support Python 3.13+.

> [!NOTE]
> On NixOS, add the package to `services.udev.packages` so non-root users get
> device access permission:
>
> ```nix
> services.udev.packages = [ nur.repos.krishnans2006.chipwhisperer ];
> ```

### GPTH

[Google Photos Takeout Helper](https://github.com/TheLastGimbus/GooglePhotosTakeoutHelper)
(`gpth`) is a Dart CLI tool that organizes a Google Photos Takeout archive into
one big chronological folder.

It is not currently packaged in nixpkgs; however, see [this PR](https://github.com/NixOS/nixpkgs/pull/414078) which has heavily inspired this derivation.

## Building/Testing

Flake-based:

```sh
nix build .#package-name
nix flake check
```

Non-flake:

```sh
nix-build -A package-name
```
