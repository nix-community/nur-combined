# Secure Boot Implementation

## Considerations

- This requires using systemd-boot, as there is no support for GRUB yet (check
  [this issue](https://github.com/nix-community/lanzaboote/issues/29))
- It does not support profiles ([yet](https://github.com/nix-community/lanzaboote/pull/541)) (check
  [this issue](https://github.com/nix-community/lanzaboote/issues/135))
- Ensure the NixOS installation works as intended and Secure Boot is disabled. Do not run these steps in a critical
  machine unless there is space for doing risky stuff (yes, sounds dramatic, but always be careful).

## Steps

- Prepare your system as stated
  [here](https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/prepare-your-system.md)
  - If using impermanence, ensure the keys are generated in a persistent place.
- Enable Secure Boot as stated
  [here](https://github.com/nix-community/lanzaboote/blob/master/docs/getting-started/enable-secure-boot.md)
  (instructions differ per machine type, or it might not be even listed, do it at your discretion)
  - In case you see an issue regarding immutable files when enrolling keys, the `--ignore-immutable` is a flag that
    might help in avoiding manipulating files you do not know about. It worked for me.

## References

- [Guide with Secure Boot and TPM implementation](https://jnsgr.uk/2024/04/nixos-secure-boot-tpm-fde)
- [More complete guide including installation](https://laniakita.com/blog/nixos-fde-tpm-hm-guide)
