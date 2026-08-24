# Nix / NUR packaging

`nur.nix` exports the `helios` package and `nixosModules.helios`. The module
can start Helios in the graphical session, run its privileged USB helper,
grant the optional DRM/KMS capability, and open the complete port set.

Validate the current release with:

```sh
nix-build packaging/nix/nur.nix -A helios --no-out-link
```

Release CI runs `update.sh vX.Y.Z`, verifies the result, and commits the new
fixed-output hashes to `main`; NUR then evaluates that file from the registered
Helios repository.
