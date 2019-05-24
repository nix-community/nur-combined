self: super: {
  pass = (super.pass.withExtensions (exts: [ exts.pass-otp ])).overrideAttrs (old:
    self.mylibs.fetchedGit ./pass.json // {
      patches = old.patches ++ [ ./pass-fix-pass-init.patch ];
    }
  );

}
