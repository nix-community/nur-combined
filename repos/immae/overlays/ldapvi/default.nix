self: super: {
  ldapvi = super.ldapvi.overrideAttrs (old: self.mylibs.fetchedGit ./ldapvi.json);
}
