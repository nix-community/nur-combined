# ulypkgs

[![Garnix badge](https://img.shields.io/endpoint.svg?url=https://garnix.io/api/badges/UlyssesZh/ulypkgs)](https://garnix.io/repo/UlyssesZh/ulypkgs)

The personal Nix packages collection of UlyssesZhan.

## Features

- Python 2 packages.
- Ren'Py 7.
- Games.

## Packages

See the [listing](https://ulysseszh.github.io/ulypkgs).

## Usage

Quick start (some packages that are marked unfree or insecure in nixpkgs may be installed in this way!):

```shell
nix run github:UlyssesZh/ulypkgs#hello
```

Add it as a flake input (some packages that are marked unfree or insecure in nixpkgs may be installed in this way!):

```nix
{
  inputs.ulypkgs.url = "github:UlyssesZh/ulypkgs";
  outputs = { self, ulypkgs }: {
    packages.x86_64-linux.hello = ulypkgs.packages.x86_64-linux.hello;
  };
}
```

If you do not want to fetch nixpkgs but use your local nixpkgs, you can use it as an overlay without flakes:

```nix
let
  ulypkgs = import <nixpkgs> {
    overlays = [
      (import "${fetchTarball "https://github.com/UlyssesZh/ulypkgs/archive/master"}/pkgs")
    ];
  };
in
ulypkgs.hello
```

You can also provide your own nixpkgs without flakes:

```nix
let
  ulypkgs = import (fetchTarball "https://github.com/UlyssesZh/ulypkgs/archive/master") {
    nixpkgs = <nixpkgs>;
    config = {
      allowUnfree = false; # this is true by default!
      permittedInsecurePackages = [ ]; # this is not empty by default!
    };
  };
in
ulypkgs.hello
```

To use it with flakes without fetching another instance of nixpkgs, you can make it follow your nixpkgs input
(some packages that are marked unfree or insecure in nixpkgs may be installed in this way!):

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.ulypkgs.url = "github:UlyssesZh/ulypkgs";
  inputs.ulypkgs.inputs.nixpkgs.follows = "nixpkgs";
  outputs = { self, ulypkgs }: {
    packages.x86_64-linux.hello = ulypkgs.packages.x86_64-linux.hello;
  };
}
```

If you want to provide more configuration options when using it as a flake input, you can use this
(you can replace `ulypkgs.call` with `import ulypkgs`, but the latter has more evaluation overhead
if there are multiple flake inputs that depend on ulypkgs):

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.ulypkgs.url = "github:UlyssesZh/ulypkgs";
  # this does not change the result but let's you fetch one less instance of nixpkgs if flake inputs are not fetched lazily
  inputs.ulypkgs.inputs.nixpkgs.follows = "nixpkgs";
  outputs = { self, ulypkgs }: {
    packages.x86_64-linux.hello = (ulypkgs.call {
      inherit nixpkgs;
      system = "x86_64-linux";
      config = {
        allowUnfree = false; # this is true by default!
        permittedInsecurePackages = [ ]; # this is not empty by default!
      };
    }).hello;
  };
}
```

You can also use it as an overlay with flakes:

```nix
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.ulypkgs.url = "github:UlyssesZh/ulypkgs";
  # this does not change the result but let's you fetch one less instance of nixpkgs if flake inputs are not fetched lazily
  inputs.ulypkgs.inputs.nixpkgs.follows = "nixpkgs";
  outputs = { self, ulypkgs }: {
    packages.x86_64-linux.hello = (import nixpkgs {
      system = "x86_64-linux";
      overlays = [ ulypkgs.overlays.default ];
    }).hello;
  };
}
```

This package collection is also available on [NUR](https://github.com/nix-community/NUR):

```shll
nix run github:nix-community/NUR#repos.ulypkgs.hello
```

## Binary caches

Binary caches are available on Garnix's public caches,
except for packages that require itch.io API keys to download sources.
Add the following lines to your Nix configuration if you trust their build infrastructure:

```ini
substituters = https://cache.garnix.io
trusted-public-keys = cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=
```

## Contributing

PRs are welcome. I can merge as long as it is an improvement even if it is not perfect.

## License

MIT.
