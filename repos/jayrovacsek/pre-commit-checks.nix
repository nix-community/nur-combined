{ self, pkgs, system }: {
  src = self;
  hooks = {
    nixfmt = {
      enable = true;
      excludes = [ ];
    };
  };
}
