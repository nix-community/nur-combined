self: super: {
  pass = super.pass.overrideAttrs (old:
    self.mylibs.fetchedGit ./pass.json // {
      patches = old.patches ++ [ ./pass-fix-pass-init.patch ];
    }
  );

}
