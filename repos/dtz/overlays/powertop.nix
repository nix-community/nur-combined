self: super: {
  powertop = super.powertop.overrideAttrs (o: rec {
    name = "powertop-2.9.0.1"; # not really
    nativeBuildInputs = (o.nativeBuildInputs or []) ++ [ self.autoreconfHook self.git ];
    src = super.fetchgit {
      url = "https://github.com/fenrus75/powertop";
      rev = "6f5edbcf4d45b8814e2d7b0fc0fe9774aafd44c1";
      sha256 = "0lsxx161yql930yl9333yxfnamm2dl14bsab2qlfn15sxbkzl0fs";
      leaveDotGit = true;
    };

    postPatch = (o.postPatch or "") + ''
      chmod +x scripts/version
      patchShebangs ./scripts/version

      ./scripts/version
    '';
  });
}
