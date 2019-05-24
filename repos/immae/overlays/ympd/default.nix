self: super: {
  ympd = super.ympd.overrideAttrs(old: self.mylibs.fetchedGithub ./ympd.json // {
    patches = (old.patches or []) ++ [ ./ympd-password-env.patch ];
  });
}
