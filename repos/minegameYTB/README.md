# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<!-- Remove this if you don't use github actions -->
![Build and populate cache](https://github.com/minegameYTB/nurpkgs-repo/workflows/Build%20and%20populate%20cache/badge.svg)

<!--
Uncomment this if you use travis:

[![Build Status](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages.svg?branch=master)](https://travis-ci.com/<YOUR_TRAVIS_USERNAME>/nur-packages)
-->
[![Cachix Cache](https://img.shields.io/badge/cachix-minegameytb-blue.svg)](https://minegameytb.cachix.org)

# How to add my cachix cache

Here an exemple of nix configuration for use the cache

```nix
{
  nix.settings = {
    substituters = [
      "https://minegameytb.cachix.org"
    ];
    trusted-public-keys = [
      "minegameytb.cachix.org-1:JvOgXYklqCayYEJWzlt0Sqc6zvs0S65ZZsWHYWh7qnc="
    ];
  };
}
```

