self: super: {
  pelican = with self.python3Packages;
    pelican.overrideAttrs(old: {
      propagatedBuildInputs = old.propagatedBuildInputs ++ [ pyyaml markdown ];
      doInstallCheck = false;
    });
}
