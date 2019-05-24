self: super: {
  pelican = with self.python3Packages;
    pelican.overrideAttrs(old: self.mylibs.fetchedGithub ./pelican.json // {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pyyaml ];
    });
}
