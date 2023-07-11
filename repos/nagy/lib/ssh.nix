{ ... }:

{
  sshKnownPublicKeys = {
    # FIXME convert this into toml, since it is only data

    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    "github.com" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gist.github.com" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    "gitlab.com" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

    "sr.ht" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMk9TEtn9KVMpxspbmvuAmVZ5xZD3w4Y6l6RfMFTFqiE";
    "git.sr.ht" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";

    "aur.archlinux.org" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuBKrPzbawxA/k2g6NcyV5jmqwJ2s+zpgZGZ7tpLIcN";

    "gitlab.freedesktop.org" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzdNH/aTnOOINO/iGupQ/rYnmKF40ESCrkRg+5JkLVN";

    # https://codeberg.org/Codeberg/org/src/branch/main/Imprint.md#ssh-fingerprints
    "codeberg.org" =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";
  };

}
