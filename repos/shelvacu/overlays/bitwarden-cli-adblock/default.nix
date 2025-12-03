# implements https://github.com/NixOS/nixpkgs/pull/400183
self: super: {
  bitwarden-cli = super.bitwarden-cli.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./remove-ad.patch ];
  });
}
