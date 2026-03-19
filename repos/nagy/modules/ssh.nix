{
  services.openssh.knownHosts = {
    # FIXME convert this into toml, since it is only data

    # https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
    "github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    "gist.github.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";

    # https://docs.gitlab.com/ee/user/gitlab_com/index.html#ssh-host-keys-fingerprints
    "gitlab.com".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";

    # https://man.sr.ht/git.sr.ht/#ssh-host-keys
    "sr.ht".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    "git.sr.ht".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";

    "aur.archlinux.org".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEuBKrPzbawxA/k2g6NcyV5jmqwJ2s+zpgZGZ7tpLIcN";

    "gitlab.freedesktop.org".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzdNH/aTnOOINO/iGupQ/rYnmKF40ESCrkRg+5JkLVN";

    # https://codeberg.org/Codeberg/org/src/branch/main/Imprint.md#ssh-fingerprints
    "codeberg.org".publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIVIC02vnjFyL+I4RHfvIGNtOgJMe769VTF1VR4EB3ZB";

    "git.wiit.one".publicKey =
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBADBObQKyvRGIgRFhC9NIfdMlWTSy0D9jup1TA8TlvB01SA4h2hX+sOb5m9Zfj01d0UdqjF4N8yawZUxr786ivAJGQAoXleby676vc0vbGWyQEzNp8V6bgNlX2dDDw0+JZX9G+3eBCJe0wL+xtXoNor7u3siHsnmDGmsf6m/+qvizpFbOA==";

  };

}
