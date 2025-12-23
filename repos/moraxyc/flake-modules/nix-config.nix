{
  flake = {
    nixConfig = {
      substituters = [
        "https://cache.nixos.org"
        "https://cache.garnix.io"
        "https://nix-cache.qaq.li/moraxyc"
        "https://moraxyc.cachix.org"
        "https://cache.nixos-cuda.org"
      ];

      extra-trusted-public-keys = [
        "moraxyc.cachix.org-1:p00BlzhjSZq23aXYuzeUF2uXdE8ikh6tq9aV1seenhQ="
        "moraxyc:fLUN1qkE59zF7jNqc2paA06LcxLzcoBMyGfWLOKU2NY="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
        "pipe-operators"
        "dynamic-derivations"
        "recursive-nix"
      ];

      allow-import-from-derivation = "true";
    };
  };
}
