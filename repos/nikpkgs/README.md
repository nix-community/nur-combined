# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/nikp123/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg)

[![Cachix Cache](https://img.shields.io/badge/cachix-nikpkgs-blue.svg)](https://nikpkgs.cachix.org)

# How do I? (Flakes only)

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
  ...
```

And this in your ``configuration.nix``:
```nix
  nix.settings = {
    extra-substituters = [
      "https://nikpkgs.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nikpkgs.cachix.org-1:d7+McnBrT0bzs/WEcd9DkjnQ3ov8mNQAzveaCCPGcJc="
    ];
  };
```

Rebuild and enjoy.

# What's in here?

Some packages I've personally made while doing stuff in nixOS. Some of these packages are pretty outdated and should be updated. 

**I DO NOT GURANTEE anything.**

The only thing I'll try to achieve is to make every package that doesn't have ``broken=true`` set work.

Pull requests and issues are welcome, though expect my response to be pretty slow. I don't have much time for playing around with stuff like this.

# License

As per what I agreed to when I attempted to publish this to the NUR, the content of this repo is licensed under MIT, unless stated otherwise.
