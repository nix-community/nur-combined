# [nur-packages][gh]

![Build and populate cache][build_cache_badge]
[![Cachix Cache][cachix_badge]][cachix]

My personal [NUR][nur] repository.

It provides a pre-compiled binary cache for NixOS unstable.
To use it add the following line to your nix.conf

Trusted Public Key: `j-k-nur.cachix.org-1:mRQf8TcRLbjJtIvdZWmnUDQ2jRlw1WE3zQuWBh9+iT8=`.

[Click here][add_binary_cache] for information on how to add a cache on NixOS or just using nix

---

Packages in this repo will be ones I think don't fit in https://github.com/nixos/nixpkgs or aren't merged in yet.
They will generally be versioned but some will be on commit SHAs where there hasn't been a tag in a while.
Once a package is merged into nixpkgs I'll update it here until it's in NixOS unstable.

[gh]: https://github.com/06kellyjac/nur-packages
[build_cache_badge]: https://github.com/06kellyjac/nur-packages/workflows/Build%20and%20populate%20cache/badge.svg
[cachix_badge]: https://img.shields.io/badge/cachix-j--k--nur-blue.svg
[cachix]: https://j-k-nur.cachix.org
[nur]: https://github.com/nix-community/NUR
[add_binary_cache]: https://nix.dev/faq.html#how-do-i-add-a-new-binary-cache
