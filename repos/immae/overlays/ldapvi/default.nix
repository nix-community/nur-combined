self: super: {
  ldapvi = super.ldapvi.overrideAttrs (old: rec {
    name = "ldapvi-${version}";
    version = "${builtins.substring 0 7 self.sources.ldapvi.rev}-${self.sources.ldapvi.ref}";
    src = self.sources.ldapvi;
  });
}
