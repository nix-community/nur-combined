# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/nikp123/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-nikpkgs-blue.svg)](https://nikpkgs.cachix.org)

# How do I set this up? (NixOS with flakes)

Put this in your ``flake.nix``:
```nix
{
  nixConfig = {
    extra-substituters = [
      "https://nikpkgs.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nikpkgs.cachix.org-1:d7+McnBrT0bzs/WEcd9DkjnQ3ov8mNQAzveaCCPGcJc="
    ];
  };
  inputs = {
    ...
    nikpkgs = {
      url                    = "github:nikp123/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
  ...
```

And this in your ``configuration.nix``:
```nix
{
  nix.settings = {
    extra-substituters = [
      "https://nikpkgs.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nikpkgs.cachix.org-1:d7+McnBrT0bzs/WEcd9DkjnQ3ov8mNQAzveaCCPGcJc="
    ];
  };
}
```

Rebuild and enjoy.

# How do I set this up? (NixOS without flakes)

For simplicity sake, set up [NUR](https://github.com/nix-community/NUR) instead.

```nix
{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
```

If you want to not have to compile packages yourself there, you can add my cachix server to your nix settings. 

```nix
{
  nix.settings = {
    extra-substituters = [
      "https://nikpkgs.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nikpkgs.cachix.org-1:d7+McnBrT0bzs/WEcd9DkjnQ3ov8mNQAzveaCCPGcJc="
    ];
  };
}
```

It should look something like that.

From there on you can use the packages from my repository by referencing
``pkgs.nur.repos.nikpkgs.the_name_of_the_package``.


# What's in here?

Some packages I've personally made while doing stuff in NixOS. Some of these packages are pretty outdated and should be updated. 

The complete package list is in the [default.nix](https://github.com/nikp123/nur-packages/blob/master/default.nix) file.

**I DO NOT GURANTEE anything.**

The only thing I'll try to achieve is to make every package that doesn't have ``broken=true`` set work.

Pull requests and issues are welcome, though expect my response to be pretty slow. I don't have much time for playing around with stuff like this.

# I am someone who knows what they're doing, how do I manually compile stuff in here?

Use ``nix-build -A name_of_the_package``.

# License

As per what I agreed to when I attempted to publish this to the NUR, the content of this repo is licensed under MIT, unless stated otherwise.

