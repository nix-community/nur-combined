# hierarchical, DNS-like mapping from <name> => ssh host/user for that name.
# host keys are represented as user keys, just with the user specified as "root".

{
  org.uninsane = rec {
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOfdSmFkrVT6DhpgvFeQKm3Fh9VKZ9DbLYOPOJWYQ0E8";
    git.root = root;
  };

  com.github = {
    # documented here: <https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints>
    # Github actually uses multiple keys -- one per format
    root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  };
}
